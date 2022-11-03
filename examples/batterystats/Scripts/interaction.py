import time
from AndroidRunner.Device import Device

default_wait_time = 4

def swipe(device: Device, x1: int, y1: int, x2: int, y2: int, sleep = 4, duration = 1000):
    device.shell('input swipe %s %s %s %s %s' % (x1, y1, x2, y2, duration))
    # time.sleep(sleep)

def tap(device: Device, x: int, y: int, sleep = 4) -> None:
    device.shell('input tap %s %s' % (x, y))
    # We need to wait for the display to update after the last click.
    # The time to update is vary. 
    # time.sleep(1)


def main(device: Device, *args, **kwargs) -> None:
    # Do task 1
    # cl
    # time.sleep(10)
    # swipe(device,6,248,560,2174)
    swipe(device,560,2174,6,248)
    tap(device, 560, 2174)
    # tap(device, 6, 248)
    # tap(device, 6, 248)
    # tap(device, 6, 248)
    
    # time.sleep(0)

    # tap(device, 560, 2174)

    # click ____
    # tap(device, 931, 2213)
    # print('hey')
    # device.shell('input swipe 300 300 500 1000')
    # device.shell('input swipe 500 1000 300 300')

   