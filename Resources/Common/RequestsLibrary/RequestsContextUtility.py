"""
Special utility library for mounting a urllib3 context onto an existing
Requests Library Session

The Requests Library ***MUST*** be declared before this library!
"""
import ssl  # needed for the cert argument

from requests import Session
from requests.adapters import HTTPAdapter
from RequestsLibrary import RequestsLibrary
from robot.api.deco import keyword, library, not_keyword
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
import urllib3
from urllib3 import PoolManager
from urllib3.util import create_urllib3_context


class AddedCipherAdapter(HTTPAdapter):
    """
    Creates a cipher adapter
    """

    def init_poolmanager(self, connections, maxsize, block=False):
        ctx = create_urllib3_context(
            ciphers=":HIGH:!DH:!aNULL",
            cert_reqs=ssl.CERT_NONE
        )
        self.poolmanager = PoolManager(
            num_pools=connections,
            maxsize=maxsize,
            block=block,
            ssl_context=ctx
        )


@library(scope="GLOBAL", version="1.0", auto_keywords=True)
class RequestsContextUtility():
    """
    This utility has one purpose: to mount a context onto
    an existing Requests Library Session
    """

    rf_builtin = BuiltIn()

    def __init__(self, disable_warnings: bool = False):
        self.rf_requests = self._get_requests_library_instance()
        if disable_warnings:
            urllib3.disable_warnings()

    @not_keyword
    def _get_requests_library_instance(self) -> RequestsLibrary:
        try:
            rf_requests = self.rf_builtin.get_library_instance(
                "RequestsLibrary")
        except (RobotNotRunningError, RuntimeError):
            rf_requests = RequestsLibrary()
        return rf_requests

    @keyword("Mount Context On Session")
    def mount_context_on_session(self, alias: str, url: str) -> None:
        """
        ``alias`` session alias
        ``url`` base url of service (without endpoint)

        Use this keyword when getting Cipher errors from requests.

        It will also be necessary to add   ``disable_warnings=${FALSE}``
        to the ``Create Session Keyword``

        Example:

        | Test Cipher
        |     Create Session    alias=${ALIAS}    url=${URL}    headers=${HEADERS}    disable_warnings=${TRUE}
        |     Mount Context On Session    ${ALIAS}    ${URL}
        |     ${response}    Post On Session    ${ALIAS}    url=${ENDPOINT}    json=${BODY}
        |     Log To Console    ${response.json()}
        """  # noqa
        session: Session = self.rf_requests._cache.switch(alias)
        session.mount(url, AddedCipherAdapter())


if __name__ == "__main__":

    pass
