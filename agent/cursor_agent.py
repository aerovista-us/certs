#!/usr/bin/env python3
import time, sys, argparse, pathlib, logging

parser = argparse.ArgumentParser()
parser.add_argument('--rules', default='/etc/nxcore-agent.rules')
args = parser.parse_args()

logging.basicConfig(filename='/var/log/nxcore/cursor-agent.log',
                    level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

def main():
    logging.info("Cursor Agent booted with rules: %s", args.rules)
    while True:
        time.sleep(30)
        logging.info("heartbeat")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.exception("Agent crashed: %s", e)
        sys.exit(1)
