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
        Retrieves all non-method attributes and their values from a session
        object.

        This method extracts all accessible attributes from the session object
        that are not methods or private attributes (those starting with '__').
        This is useful for debugging or inspecting the complete state of a
        session.

        Args:
            alias (str): The session alias/name to retrieve data from

        Returns:
            dict[str, Any]: Dictionary containing all session attributes and
                their values

        Example:
            | ${session_data}= | Get All Data | my_session |
            | Log | ${session_data} |
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
        Retrieves the session adapter objects used for HTTP requests.

        Session adapters handle the connection pooling and HTTP protocol
        implementation for different URL schemes (http, https, etc.).

        Args:
            alias (str): The session alias/name to retrieve adapters from

        Returns:
            MutableMapping[Any, Any]: Dictionary mapping URL schemes to their
                corresponding adapter objects

        Example:
            | ${adapters}= | Get Session Adapters | my_session |
            | Log | ${adapters} |
        """
        session = self._get_session_object(alias)
        return session.adapters

    @keyword("Get Session Auth")
    def get_session_auth(self, alias: str) -> HTTPBasicAuth:
        """
        Retrieves the authentication object configured for the session.

        Returns the authentication handler (e.g., HTTPBasicAuth,
        HTTPDigestAuth) that is used for all requests made with this session.

        Args:
            alias (str): The session alias/name to retrieve auth from

        Returns:
            HTTPBasicAuth: The authentication object, or None if no auth is
                configured

        Example:
            | ${auth}= | Get Session Auth | my_session |
            | Log | ${auth} |
        """
        session = self._get_session_object(alias)
        return session.auth

    @keyword("Get Session Certificate")
    def get_session_certificate(self, alias: str) -> tuple | None:
        """
        Retrieves the SSL certificate configuration for the session.

        Returns the client certificate and key files configured for SSL/TLS
        authentication with the server.

        Args:
            alias (str): The session alias/name to retrieve certificate from

        Returns:
            tuple | None: Tuple containing (cert_file, key_file) or None if no
                certificates are configured

        Example:
            | ${certs}= | Get Session Certificate | my_session |
            | Log | ${certs} |
        """
        session = self._get_session_object(alias)
        return session.cert

    @keyword("Get Session Cookies")
    def get_session_cookies(self, alias: str) -> dict:
        """
        Retrieves all cookies stored in the session.

        Returns a dictionary of all cookies that have been set for this
        session, including cookies received from server responses and manually
        added cookies.

        Args:
            alias (str): The session alias/name to retrieve cookies from

        Returns:
            dict: Dictionary mapping cookie names to their values

        Example:
            | ${cookies}= | Get Session Cookies | my_session |
            | Log | ${cookies} |
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
