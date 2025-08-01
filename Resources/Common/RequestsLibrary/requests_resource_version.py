#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Requests Library Resource for Robot Framework Automation Projects
"""

__author__ = "Kelby Stine"
__authors__ = []
__contact__ = "kelby.stine@sovos.com"
__copyright__ = "Copyright 2025, Sovos Inc."
__credits__ = []
__date__ = "2025/08/01"
__deprecated__ = False
__email__ = "kelby.stine@sovos.com"
__license__ = ""
__maintainer__ = "developer"
__status__ = "Production"
__version__ = "1.1.0"


def get_requests_resource_metadata() -> dict:
    """
    Prints all the metadata stats.

    Returns:
        dict: Metadata stats
    """

    stats = {
        "author": __author__,
        "authors": __authors__,
        "contact": __contact__,
        "copyright": __copyright__,
        "credits": __credits__,
        "date": __date__,
        "deprecated": __deprecated__,
        "email": __email__,
        "license": __license__,
        "maintainer": __maintainer__,
        "status": __status__,
        "version": __version__
    }
    print("Requests Library Resource Metadata")
    for stat, value in stats.items():
        print(f"{stat}: {value}")
    return stats
