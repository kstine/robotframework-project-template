#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Browser Utilities Plugin
"""
from Browser import Browser
from Browser.base.librarycomponent import LibraryComponent
from robot.api.deco import keyword
from robot.api.logger import logging


class BrowserUtilitiesPlugin(LibraryComponent):
    """
    A set of utilities for common Browser actions
    """

    def __init__(self, library: Browser):
        super().__init__(library)

    @keyword("Get List Of Texts")
    def get_list_of_texts(self,
                          selector: str,
                          filter_empty: bool = False
                          ) -> list[str]:
        """
        Returns a list of text from the given selector

        Args:
            selector (str): Browser selector
            filter_empty (bool, optional):
                            Remove empty values.
                            Defaults to False.

        Returns:
            list[str]: list of element texts
        """
        elements = self.library.get_elements(selector)
        texts = []
        for element in elements:
            try:
                text = self.library.get_text(element)
                texts.append(text)
            except AssertionError as error:
                logging.warning(error)
        if filter_empty:
            texts = [text for text in texts if text]
        return texts

    @keyword("Try To Scroll To Last Row")
    def try_to_scroll_to_last_row(self,
                                  selector: str,
                                  scrolls: str = "1") -> None:
        """
        Makes an effort to scroll to the last row.

        Args:
            selector (str): Browser selector
            scrolls (str, optional):
                            Number of scroll attempts.
                            Defaults to "1".
        """
        for i in range(int(scrolls)):
            logging.info(f"Scrolls: {i}")
            elements = self.library.get_elements(selector)
            try:
                self.library.scroll_to_element(elements[-1])
            except AssertionError:
                break

    @keyword("Drag And Drop Using Mouse Move")
    def drag_and_drop_using_mouse_move(self,
                                       from_x: str,
                                       from_y: str,
                                       to_x: str,
                                       to_y: str,
                                       time_delta: str = '256ms'
                                       ) -> None:
        """
        This is an option if time is needed between Mouse Move and
        Mouse Button Steps
        Especially when the Drag And Drop By Coordinates Browser keyword
         is too fast.

        Args:
            from_x (str): from x coordinate
            from_y (str): from y coordinate
            to_x (str): to x coordinate
            to_y (str): to y coordinate
            time_delta (str, optional):
                        Wait time between mouse actions.
                        Defaults to '256ms'.
        """
        Browser.mouse_move(from_x, from_y, steps="1")
        self.library.sleep(time_delta)
        self.library.mouse_button("down")
        self.library.sleep(time_delta)
        self.library.mouse_move(to_x, to_y, steps="1")
        self.library.sleep(time_delta)
        self.library.mouse_button("up")
