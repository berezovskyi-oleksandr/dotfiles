import requests
import time
import re
from functools import reduce


class Py3status:
    cache_timeout = 600
    url = 'http://minfin.com.ua/data/currency/ib/eur.ib.stock.json'

    def usd_currency(self):

        resp = requests.get(self.url)
        resp.raise_for_status()
	
        entry = resp.json()[-1]
        return {
            'full_text': "M €{:.2f}/{:.2f}".format(float(entry['bid']), float(entry['ask'])),
            'cached_until': time.time() + self.cache_timeout
        }


if __name__ == '__main__':
    """
    Run module in test mode.
    """
    from py3status.module_test import module_test

    module_test(Py3status)


