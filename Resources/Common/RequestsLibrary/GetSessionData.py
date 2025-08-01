"""
Keyword library for retrieving session objects and information.

The Requests Library ***MUST*** be declared before this library!
"""

from collections.abc import MutableMapping
from typing import Any

from requests import Session
from requests.auth import HTTPBasicAuth
from RequestsLibrary import RequestsLibrary
from robot.api.deco import keyword, library, not_keyword
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


@library(scope="GLOBAL", version="1.1", auto_keywords=True)
class GetSessionData():
    """
    Additional Get Session Keywords for the Requests Library.
    """

    def __init__(self):
        self.rf_requests = self._get_requests_library_instance()

    @not_keyword
    def _get_requests_library_instance(self) -> RequestsLibrary:
        try:
            rf_requests = BuiltIn().get_library_instance(
                "RequestsLibrary")
        except (RobotNotRunningError, RuntimeError):
            rf_requests = RequestsLibrary()
        return rf_requests

    @not_keyword
    def _get_session_object(self, alias: str) -> Session:
        session: Session = self.rf_requests._cache.switch(alias)
        return session

    @not_keyword
    def _is_methodless_attributes(self, session: Session, attr: str) -> bool:
        return (not attr.startswith('__')) and (
            not callable(getattr(session, attr)))

    @keyword("Get All Data")
    def get_all_data(self, alias: str) -> dict[str, Any]:
        """
        _summary_

        Args:
            alias (str): _description_

        Returns:
            dict[str, Any]: _description_
        """
        session: Session = self.rf_requests._cache.switch(alias)
        all_attributes = [
            attr for attr in dir(session) if (
                self._is_methodless_attributes(session, attr))
        ]
        all_data = {attr: getattr(session, attr) for attr in all_attributes}
        return all_data

    @keyword("Get Session Adapters")
    def get_session_adapters(self, alias: str) -> MutableMapping[Any, Any]:
        """
        Gets the session adapter objects.

        Args:
            alias (str): required

        Returns:
            MutableMapping[Any, Any]: map of adapters
        """
        session = self._get_session_object(alias)
        return session.adapters

    @keyword("Get Session Auth")
    def get_session_auth(self, alias: str) -> HTTPBasicAuth:
        """
        Get the session auth object

        Args:
            alias (str): required

        Returns:
            HTTPBasicAuth: auth object
        """
        session = self._get_session_object(alias)
        return session.auth

    @keyword("Get Session Certificate")
    def get_session_certificate(self, alias: str) -> tuple | None:
        """
        Get the session certs.

        Args:
            alias (str): required

        Returns:
            tuple | None: certs
        """
        session = self._get_session_object(alias)
        return session.cert

    @keyword("Get Session Cookies")
    def get_session_cookies(self, alias: str) -> dict:
        """
        Gets session cookies.

        Args:
            alias (str): required

        Returns:
            dict: cookies
        """
        session = self._get_session_object(alias)
        return session.cookies.get_dict()

    @keyword("Get Session Headers")
    def get_session_headers(self, alias: str) -> dict:
        """
        Gets session headers.

        Args:
            alias (str): required

        Returns:
            dict: headers
        """
        session = self._get_session_object(alias)
        return session.headers

    @keyword("Get Session Hooks")
    def get_session_hooks(self, alias: str) -> dict:
        """
        Gets session hooks.

        Args:
            alias (str): required

        Returns:
            dict: hooks
        """
        session = self._get_session_object(alias)
        return session.hooks

    @keyword("Get Session Max Redirects")
    def get_session_max_redirects(self, alias: str) -> int:
        """
        Gets session max redirects.

        Args:
            alias (str): required

        Returns:
            int: max redirects
        """
        session = self._get_session_object(alias)
        return session.max_redirects

    @keyword("Get Session Object")
    def get_session_object(self, alias: str) -> Session:
        """
        Gets session object.

        Args:
            alias (str): required

        Returns:
            Session: session object
        """
        session = self._get_session_object(alias)
        return session

    @keyword("Get Session Params")
    def get_session_params(self, alias: str) -> dict:
        """
        Gets session params.

        Args:
            alias (str): required

        Returns:
            dict: params
        """
        session = self._get_session_object(alias)
        return session.params

    @keyword("Get Session Proxies")
    def get_session_proxies(self, alias: str) -> dict:
        """
        Gets session proxies.

        Args:
            alias (str): required

        Returns:
            dict: proxies
        """
        session = self._get_session_object(alias)
        return session.proxies

    @keyword("Get Session Stream")
    def get_session_stream(self, alias: str) -> bool:
        """
        Gets session stream status.

        Args:
            alias (str): required

        Returns:
            bool: stream status
        """
        session = self._get_session_object(alias)
        return session.stream

    @keyword("Get Session Trust Environment")
    def get_session_trust_env(self, alias: str) -> bool:
        """
        Gets session trust env.

        Args:
            alias (str): required

        Returns:
            bool: trust env status
        """
        session = self._get_session_object(alias)
        return session.trust_env

    @keyword("Get Session URL")
    def get_session_url(self, alias: str) -> str:
        """
        Gets session url.

        Args:
            alias (str): required

        Returns:
            str: url
        """
        session = self._get_session_object(alias)
        return session.url

    @keyword("Get Session SSL Verification")
    def get_session_verify(self, alias: str) -> bool:
        """
        Gets session verify status.

        Args:
            alias (str): required

        Returns:
            bool: verify status
        """
        session = self._get_session_object(alias)
        return session.verify


if __name__ == "__main__":

    pass
