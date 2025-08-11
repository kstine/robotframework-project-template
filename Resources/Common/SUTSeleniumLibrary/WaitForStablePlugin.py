from SeleniumLibrary.base import LibraryComponent, keyword
from robot.libraries.BuiltIn import BuiltIn
from SeleniumLibrary.keywords.waiting import WaitingKeywords
from typing import Optional, Union
from datetime import timedelta
from selenium.webdriver.remote.webelement import WebElement
from robot.api.logger import logging


class WaitForStablePlugin(LibraryComponent):
    """
    This plugin is used to wait for an element to be stable.
    """

    def __init__(self, ctx):
        LibraryComponent.__init__(self, ctx)
        self.waiting_keywords = WaitingKeywords(self.ctx)

    @keyword
    def wait_until_element_is_stable(
            self,
            locator: Union[WebElement, None, str],
            timeout: Optional[timedelta] = None,
            error: Optional[str] = None,
            time_delta: Optional[str] = None):
        """
        Waits until the element ``locator`` is stable.
        Checks for visibility then calculates if the element has changed
        position.

        Fails if ``timeout`` expires before the element is stable. See
        the `Timeouts` section for more information about using timeouts and
        their default value and the `Locating elements` section for details
        about the locator syntax.

        ``error`` can be used to override the default error message.

        Args:
            locator (Union[WebElement, None, str]): The locator of the element
                                                    to check.
            timeout (Optional[timedelta]): The timeout to wait before the
                                           element is stable.
            error (Optional[str]): The error message to display if the element
                                   is not stable.
            time_delta (Optional[str]): The time delta to wait before checking
                                        if the element is stable.
        """
        self.waiting_keywords._wait_until(
            lambda: self.element_should_be_stable(locator, time_delta),
            f"Element '{locator}' not stable after <TIMEOUT>.",
            timeout,
            error,
        )

    @keyword
    def element_should_be_stable(
            self,
            locator: Union[WebElement, None, str],
            time_delta: Optional[str] = None
    ) -> bool:
        """Verifies that the element identified by ``locator`` is stable.
        Checks for visibility then calculates if the element has changed
        position.

        Herein, visible means that the element is logically visible, not
        optically visible in the current browser viewport. For example,
        an element that carries ``display:none`` is not logically visible,
        so using this keyword on that element would fail.

        See the `Locating elements` section for details about the locator
        syntax.

        The ``message`` argument can be used to override the default error
        message.

        Args:
            locator (Union[WebElement, None, str]): The locator of the element
                                                    to check.
            time_delta (Optional[str]): The time delta to wait before checking
                                        if the element is stable.

        Returns:
            (bool): True if the element is stable, False otherwise.
        """
        time_delta = self._get_default_time_delta(time_delta)
        self.is_visible(locator)
        initial = self._get_x_y_location(locator)
        BuiltIn().sleep(time_delta)
        final = self._get_x_y_location(locator)
        return initial == final

    def _get_x_y_location(
            self,
            locator: Union[WebElement, None, str]
    ) -> tuple[int, int]:
        logging.info(locator)
        element = self.find_element(locator)
        return (element.location["x"], element.location["y"])

    def _get_default_time_delta(self, time_delta: Optional[str] = "265ms"):
        return time_delta
