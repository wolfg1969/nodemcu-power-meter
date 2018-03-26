import serial
import time
from struct import unpack

command = '010300480008C41A'

def send_command(ser):
  ser.write('\x01')
  ser.write('\x03')
  ser.write('\x00')
  ser.write('\x48')
  ser.write('\x00')
  ser.write('\x08')
  ser.write('\xC4')
  ser.write('\x1A')

with serial.Serial("/dev/tty.wchusbserial1420", 4800, timeout=5) as ser:
  
  while(True):

    send_command(ser)
    #time.sleep(0.2)

    raw = ser.read(size=37)
    # print type(data), len(data)
    print raw.encode('hex')
    data = unpack('>BBBLLLLLLLLH', raw)
    print 'V =', data[3]/10000.0, 'A =', data[4]/10000.0, 'Power:', data[5]/10000.0, data[6]/10000.0, data[7]/1000.0, data[8]/10000.0
    time.sleep(1)

