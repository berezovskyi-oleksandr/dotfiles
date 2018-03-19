import requests
import time
import re
from bs4 import BeautifulSoup
from functools import reduce


class Py3status:
    cache_timeout = 600
    url = 'https://www.kharkovforum.com/forumdisplay.php?f=110'
    regex = re.compile(r"(?:Евро|евро|eur|EUR|E-) ?(?P<buy>\d{1,2}[.,]\d{1,2})[.\-\/](?P<sell>\d{1,2}[.,]\d{1,2})")

    def eur_currency(self):

        resp = requests.get(self.url)
        resp.raise_for_status()
        bs = BeautifulSoup(resp.text, "html5lib")
        table = bs.find('table', {'id': 'threadslist'})

        res = []
        for tr in table.find_all('tbody')[1].find_all('tr')[1:]:
            if tr.get('valign'):
                break
            rx = self.regex.findall(str(tr))
            if len(rx):
                res.append(rx[0])

        values = (reduce(lambda x, y: x + float(y[0].replace(',','.')), res, 0) / len(res),
                  reduce(lambda x, y: x + float(y[1].replace(',','.')), res, 0) / len(res),
                  # max([float(el[0]) for el in res]),
                  # min([float(el[1]) for el in res]),
                  )

        return {
            # 'full_text': "Kh €{:.2f}/{:.2f} ({:.2f}/{:.2f})".format(*values),
            'full_text': "K €{:.2f}/{:.2f}".format(*values),
            'cached_until': time.time() + self.cache_timeout
        }


if __name__ == '__main__':
    """
    Run module in test mode.
    """
    from py3status.module_test import module_test

    module_test(Py3status)

