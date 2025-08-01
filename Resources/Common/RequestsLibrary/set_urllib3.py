"""
Library specifically to set the DEFAULT_CIPHERS
Requires urllib3 version < 2.0.0
DEPRECATED
Use `Mount Context On Session` from RequestsContextUtility.py
"""
import urllib3
from urllib3.util import ssl_

# Line kept for reference
# DEFAULT_CIPHER = ":HIGH:!DH:!aNULL"
DEFAULT_CIPHER = ":!DH"


def set_urllib3():
    """
    Sets urllib3 warnings and default ciphers
    DEPRECATED
    """
    urllib3.disable_warnings()
    if urllib3.__version__ < "2.0.0":
        ssl_.DEFAULT_CIPHERS += DEFAULT_CIPHER
