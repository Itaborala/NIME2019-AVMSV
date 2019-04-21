#!/usr/bin/env python

#import pygtk
#pygtk.require('2.0')
#import gtk
from gi.repository import Gtk
from gi.repository import Gdk
#from gi.repository import GObject
import getopt
import sys
import liblo
import math
import threading
import time
import signal

Gdk.threads_init()
#gtk.gdk.threads_init()

def db_to_coeff(db):
	if db > -318.8:
		return math.pow(10.0, db * 0.05)
	else:
		return 0.0

def coeff_to_db(coeff):
	if coeff == 0.0:
		return float('-inf')
	else:
		return 20.0 * math.log10(coeff)

def fader_to_db(fader):
	if fader == 0.0:
		return float('-inf')
	log = math.log10(fader * 1.3422)
	if fader > 0.745:
		return 78.25 * log
	else:
		return 93.44 * log

def db_to_fader(db):
	if db > -318.8:
		if db > 0.0:
			return 0.745 * math.pow(10.0, db*0.01277955272)
		else:
			return 0.745 * math.pow(10.0, db*0.01070205479)
	else:
		return 0.0

def scroll2str(scroll):
	if scroll == Gtk.ScrollType.NONE:
		return "NONE"
	elif scroll == Gtk.ScrollType.JUMP:
		return "JUMP"
	elif scroll == Gtk.ScrollType.STEP_BACKWARD:
		return "STEP_BACKWARD"
	elif scroll == Gtk.ScrollType.STEP_FORWARD:
		return "STEP_FORWARD"
	elif scroll == Gtk.ScrollType.PAGE_BACKWARD:
		return "PAGE_BACKWARD"
	elif scroll == Gtk.ScrollType.PAGE_FORWARD:
		return "PAGE_FORWARD"
	elif scroll == Gtk.ScrollType.STEP_UP:
		return "STEP_UP"
	elif scroll == Gtk.ScrollType.STEP_DOWN:
		return "STEP_DOWN"
	elif scroll == Gtk.ScrollType.PAGE_UP:
		return "PAGE_UP"
	elif scroll == Gtk.ScrollType.PAGE_DOWN:
		return "PAGE_DOWN"
	elif scroll == Gtk.ScrollType.STEP_LEFT:
		return "STEP_LEFT"
	elif scroll == Gtk.ScrollType.STEP_RIGHT:
		return "STEP_RIGHT"
	elif scroll == Gtk.ScrollType.PAGE_LEFT:
		return "PAGE_LEFT"
	elif scroll == Gtk.ScrollType.PAGE_RIGHT:
		return "PAGE_RIGHT"
	elif scroll == Gtk.ScrollType.START:
		return "START"
	elif scroll == Gtk.ScrollType.END:
		return "END"


class VolumeOSC(threading.Thread):
	def __init__(self, gui, host, port, protocol, instance, local_port):
		threading.Thread.__init__(self)
		self.daemon = True
		self.gui = gui
		self.address = liblo.Address(host, port, protocol)
		self.server_active = False
		try:
			searching_port = True
			ntrials = 0
			while searching_port:
				try:
					self.server = liblo.Server(local_port)
					searching_port = False
				except liblo.ServerError, err:
					local_port = local_port + 1
					ntrials = ntrials + 1
					if ntrials > 1000:
						raise liblo.ServerError(99, "stop searching free port", None)

			self.server.add_method("/net/mhcloud/volume/" + instance + "/master", "f", self.callback_master_gain)
			self.server.add_method("/net/mhcloud/volume/" + instance + "/master/mute", "i", self.callback_master_mute)
			for i in range(channels):
				self.server.add_method("/net/mhcloud/volume/" + instance + "/" + str(i), "f", self.callback_channel_gain, i)
				self.server.add_method("/net/mhcloud/volume/" + instance + "/" + str(i) + "/mute", "i", self.callback_channel_mute, i)
			self.server_active = True
		except liblo.ServerError, err:
			sys.stderr.write("OSC server error occured:\n")
			sys.stderr.write(str(err) + '\n')

	def run(self):
		while self.server_active:
			self.server.recv(100)

	def callback_master_gain(self, path, args):
		Gdk.threads_enter()
		self.gui.fader_event_safe(-1, args[0], False)
		Gdk.threads_leave()

	def callback_master_mute(self, path, args):
		Gdk.threads_enter()
		self.gui.mute_event_safe(-1, args[0]!=0, False)
		Gdk.threads_leave()

	def callback_channel_gain(self, path, args, types, src, data):
		Gdk.threads_enter()
		self.gui.fader_event_safe(data, args[0], False)
		Gdk.threads_leave()

	def callback_channel_mute(self, path, args, types, src, data):
		Gdk.threads_enter()
		self.gui.mute_event_safe(data, args[0]!=0, False)
		Gdk.threads_leave()

	def send_master(self, val):
		liblo.send(self.address, "/net/mhcloud/volume/" + instance + "/master", val)

	def send_channel(self, channel, val):
		liblo.send(self.address, "/net/mhcloud/volume/" + instance + "/" + str(channel), val)

	def send_master_mute(self, mute):
		liblo.send(self.address, "/net/mhcloud/volume/" + instance + "/master/mute", int(mute))

	def send_channel_mute(self, channel, mute):
		liblo.send(self.address, "/net/mhcloud/volume/" + instance + "/" + str(channel) + "/mute", int(mute))

class VolumeGUI:

	def delete_event(self, widget, event, data=None):
		print "delete event occurred"
		return False

	def destroy(self, widget, data=None):
		print "destroy signal occurred"
		Gtk.main_quit()

	def send_master_osc(self, value):
		self.osc.send_master(value)

	def send_channel_osc(self, channel, value):
		self.osc.send_channel(channel, value)

	def send_master_mute(self, mute):
		self.osc.send_master_mute(mute)

	def send_channel_mute(self, channel, mute):
		self.osc.send_channel_mute(channel, mute)

	def mute_event(self, ch, mute, send_osc):
		self.set_mute(ch, mute)
	
		if send_osc:
			if ch == self.nchannels-1:
				self.send_master_mute(self.muted[ch])
			else:
				self.send_channel_mute(ch, self.muted[ch])

	def mute_event_safe(self, ch, mute, send_osc):
		self.lock.acquire()
		self.mute_event(ch, mute, send_osc)
		self.lock.release()

	def fader_event(self, ch, gain_abs, send_osc):
		if send_osc:
			if ch == self.nchannels-1:
				self.send_master_osc(gain_abs)
			else:
				self.send_channel_osc(ch, gain_abs)
#		print "fader_event ch=" + str(ch) + " gain=" + str(gain_abs)
		gain_db = coeff_to_db(gain_abs)
		if ch == -1:
			ch = self.nchannels-1
#		print "fader_event ch=" + str(ch) + " gain=" + str(gain_abs)
		self.vscales[ch].set_value(db_to_fader(gain_db))
		self.dbs[ch].set_text(str(gain_db))

	def fader_event_safe(self, ch, gain_abs, send_osc):
		self.lock.acquire()
		self.fader_event(ch, gain_abs, send_osc)
		self.lock.release()

	def scale_event(self, scale, scrolltype, value):
		#print "scroll=" + scroll2str(scrolltype)
		if scrolltype == Gtk.ScrollType.STEP_FORWARD:
			value += 0.01
		elif scrolltype == Gtk.ScrollType.STEP_BACKWARD:
			value -= 0.01
		elif scrolltype == Gtk.ScrollType.PAGE_FORWARD:
			value += 0.1
		elif scrolltype == Gtk.ScrollType.PAGE_BACKWARD:
			value -= 0.1
		value = min(value, 1.0)
		value = max(value, 0.0)

		channel = 0
		for i, val in enumerate(self.vscales):
			if scale == self.vscales[i]:
				#print "scale found"
				channel = i
		self.fader_event_safe(channel, db_to_coeff(fader_to_db(value)), True)
		return True

	def activate_event(self, entry):
		gain_db = float(entry.get_text().replace(',', '.'))
		gain_db = min(gain_db, 10.0)

		channel = 0
		for i, item in enumerate(self.dbs):
			if entry == self.dbs[i]:
				channel = i

		gain_abs = db_to_coeff(gain_db)
		self.fader_event_safe(channel, gain_abs, True)

	def click_mute(self, button):
		channel = 0
		for i, item in enumerate(self.mutes):
			if button == self.mutes[i]:
				channel = i

		self.mute_event_safe(channel, not self.muted[channel], True)

	def change_color(self, channel, mute):
		if mute:
			self.mutes[channel].override_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(65535,0,0,1))
			self.mutes[channel].override_color(Gtk.StateFlags.ACTIVE, Gdk.RGBA(55535,0,0,1))
			self.mutes[channel].override_color(Gtk.StateFlags.PRELIGHT, Gdk.RGBA(65535,0,0,1))
		else:
			self.mutes[channel].override_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(0,65535,0,1))
			self.mutes[channel].override_color(Gtk.StateFlags.ACTIVE, Gdk.RGBA(0,55535,0,1))
			self.mutes[channel].override_color(Gtk.StateFlags.PRELIGHT, Gdk.RGBA(0,65535,0,1))

#			if mute:
#				self.mutes[channel].modify_bg(gtk.STATE_NORMAL, gtk.gdk.Color(65535,0,0))
#				self.mutes[channel].modify_bg(gtk.STATE_ACTIVE, gtk.gdk.Color(55535,0,0))
#				self.mutes[channel].modify_bg(gtk.STATE_PRELIGHT, gtk.gdk.Color(65535,0,0))
#			else:
#				self.mutes[channel].modify_bg(gtk.STATE_NORMAL, gtk.gdk.Color(0,65535,0))
#				self.mutes[channel].modify_bg(gtk.STATE_ACTIVE, gtk.gdk.Color(0,55535,0))
#				self.mutes[channel].modify_bg(gtk.STATE_PRELIGHT, gtk.gdk.Color(0,65535,0))

	def set_mute(self, channel, mute):
		if (self.muted[channel] != mute):
			self.muted[channel] = mute
			self.change_color(channel, mute)

	def __init__(self, nchannels, host, port, protocol, instance, local_port):
		self.lock = threading.Lock()
		self.osc = VolumeOSC(self, host, port, protocol, instance, local_port)
		self.osc.start()
		self.nchannels = nchannels
		print "channels=" + str(self.nchannels)

		if self.nchannels == 1:
			self.nchannels = 0

		self.nchannels += 1
		self.vscales = [None]*self.nchannels
		self.dbs = [None]*self.nchannels
		self.mutes = [None]*self.nchannels
		self.muted = [None]*self.nchannels

#		self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
		self.window = Gtk.Window()
		self.window.connect("delete_event", self.delete_event)
		self.window.connect("destroy", self.destroy)
		self.window.set_border_width(10)

		self.table = Gtk.Table(4, channels)

		for i, val in enumerate(self.vscales):
			self.vscales[i] = Gtk.Scale.new_with_range(Gtk.Orientation.VERTICAL, 0.0, 1.0, 0.01)
			self.vscales[i].set_digits(2)
			self.vscales[i].set_draw_value(False)
			#self.vscales[i].set_range(0, 1)
			self.vscales[i].set_value(db_to_fader(0.0))
			self.vscales[i].set_inverted(True)
			self.vscales[i].connect("change-value", self.scale_event)
			self.table.attach(self.vscales[i], i, i+1, 2, 3)
			self.vscales[i].show()

			self.mutes[i] = Gtk.Button("Mute")
			self.set_mute(i, False)
#			self.send_channel_mute(i, False)
			self.mutes[i].connect("clicked", self.click_mute)
#			self.table.attach(self.mutes[i], i, i+1, 0, 1, gtk.SHRINK, gtk.SHRINK)
			self.table.attach(self.mutes[i], i, i+1, 0, 1, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.SHRINK)
			self.mutes[i].show()

			self.dbs[i] = Gtk.Entry()
			self.dbs[i].set_text("0.0")
			self.dbs[i].set_width_chars(4)
			self.dbs[i].connect("activate", self.activate_event)
			self.dbs[i].show()
#			self.table.attach(self.dbs[i], i, i+1, 1, 2, gtk.SHRINK, gtk.SHRINK)
			self.table.attach(self.dbs[i], i, i+1, 1, 2, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.SHRINK)
			if (i != self.nchannels-1):
#				self.send_channel_osc(i, db_to_coeff(0.0))
				label = Gtk.Label("Channel "+str(i+1))
#				self.table.attach(label, i, i+1, 3, 4, gtk.SHRINK, gtk.FILL)
				self.table.attach(label, i, i+1, 3, 4, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.FILL)
				label.show()
#self.table.attach(self.vscales[i], i, i+1, 0, 1)

#		self.send_master_osc(db_to_coeff(0.0))
#		self.send_master_mute(False)

		master = Gtk.Label("Master")
#		self.table.attach(master, self.nchannels-1, self.nchannels, 3, 4, gtk.FILL, gtk.FILL)
		self.table.attach(master, self.nchannels-1, self.nchannels, 3, 4, Gtk.AttachOptions.FILL, Gtk.AttachOptions.FILL)
		master.show()
		
		self.window.add(self.table)
		self.window.set_size_request(self.nchannels*90, 300)
#		self.window.set_position(gtk.WIN_POS_CENTER)
#		self.window.set_position(Gtk.WindowPosition.CENTER)
		self.table.show()
		self.window.show()

	def main(self):
		Gtk.main()

	def get_nchannels(self):
		return self.nchannels


if __name__ == "__main__":
	signal.signal(signal.SIGINT, signal.SIG_DFL)
	channels = 6
	port = 7600
	host = "localhost"
	protocol = liblo.UDP
	instance = "jack-volume"
	local_port = 7601

	try:
		opts, args = getopt.getopt(sys.argv[1:], "c:p:h:j:uts:")
	except getopt.GetoptError as err:
		sys.stderr.write(str(err) + '\n')
		sys.stderr.write("usage: " + sys.argv[0] + " [-c <nchannels>] [-p <port>] [-h <host>] [-j <jack-volume_instance>] [-u] [-t] [-s <listen-port>]\n")
		sys.stderr.write("options:\n")
		sys.stderr.write("-c  number of channels\n")
		sys.stderr.write("-h  OSC server host\n")
		sys.stderr.write("-p  network port\n")
		sys.stderr.write("-t  send OSC over TCP\n")
		sys.stderr.write("-u  send OSC over UDP\n")
		sys.stderr.write("-j  name of the jack-volume instance\n")
		sys.stderr.write("-s  jvctl OSC UDP listening port\n")
		sys.exit(2)
	for k, v in opts:
		if k == "-c":
			channels = v
		elif k == "-p":
			port = int(v)
			local_port = port + 1
		elif k == "-h":
			host = v
		elif k == "-j":
			instance = v
		elif k == "-u":
			protocol = liblo.UDP
		elif k == "-t":
			protocol = liblo.TCP
		elif k == "-s":
			local_port = int(v)
	channels = int(channels)
	channels = min(channels, 32)
	channels = max(channels, 1)
	try:
		ctrl = VolumeGUI(channels, host, port, protocol, instance, local_port)
		ctrl.main()
	except IOError:
		sys.stderr.write("IOError occured:\n")
		sys.stderr.write(str(IOError) + '\n')
