import time
from AndroidRunner.Device import Device

default_wait_time = 4

def tap(device: Device, x: int, y: int, sleep = 4) -> None:
    device.shell('input tap %s %s' % (x, y))
    # We need to wait for the display to update after the last click.
    # The time to update is vary. 
    # time.sleep(1)


def main(device: Device, *args, **kwargs) -> None:
    # Do task 1
    # click ____
    time.sleep(6)
    tap(device, 516, 1930)


    tap(device, 560, 2174)

    # click ____
    tap(device, 931, 2213)

   