import requests
import time
from bs4 import BeautifulSoup


class Py3status:
    cache_timeout = 600
    url = 'https://my.ukrsibbank.com'

    def eur_currency(self):

        resp = requests.get(self.url)
        resp.raise_for_status()
	
        bs = BeautifulSoup(resp.text, 'html5lib')
        r = bs.find('div', {'id': 'BNUAHEUR', 'class': 'rate__result'})
        sell = float(' '.join(r.find('div', {'class': 'rate__buy'}).p.text.split()))
        block = float(' '.join(r.find('div', {'class': 'rate__sale'}).p.text.split()))
        return {
            'full_text': "U €{:.2f}/{:.2f}".format(block, sell),
            'cached_until': time.time() + self.cache_timeout
        }


if __name__ == '__main__':
    """
    Run module in test mode.
    """
    from py3status.module_test import module_test

    module_test(Py3status)


