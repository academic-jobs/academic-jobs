# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
from pymysql import cursors, connect
import sys
from itertools import chain

class JobsPipeline(object):

    def __init__(self):
        # Open the connection to the database and leave open
        self.connection = self.open_connection()

    def _check_type(ar, data_type):
        """Raises an error if ar is not of the type given"""
        if not type(ar) == data_type:
            raise TypeError("Only {} types are supported. Got {}.".format(data_type,
                                                                          type(ar)))

    def open_connection(self):
        """Opens a connection to the database and keeps it open."""
        connection = connect(host = 'localhost',
                                  user = 'olivia',
                                  password = 'owilsoli',
                                  db = 'academic',
                                  charset = 'utf8mb4')
        return connection

    def get_unis_subs(self, unis, ):
        """Gets a dict of unique universities using self.connection

        Parameters
        ----------
        unis: bool
            Whether to get unique list of univeristy names and ids.
        subs: bool
            Whether to get unique list of main subject areas and ids.
        """
        try:
            with self.connection.cursor() as cursor:
                # query the jobs table, getting the lowercase uni_name
                sql = "SELECT LOWER(`uni_name`), `id` FROM `university`"
                cursor.execute(sql)
                t = cursor.fetchall()
                # puts the items fetched into a dict with the key being
                # uni_name and the value being the id
                dict_of_unis = {item[0]: item[1] for item in t}
        except:
            print("Oops. Either the connection is bad, or your sql didn't "
                  "work", sys.exc_info()[0])

    def insert_item(self, table, name):
        """Inserts a new item into the relevant table, creating the SQL required.

        This should only be used for the universities or subject tables. This
        uses the fact that each item in these tables should be unique and
        therefore the length of the unique list is also the number of items
        in the table.

        Parameters
        ----------
        table: String
            Name of the table to be inserted into.
        item: String
            Name of the item to be inserted. For example 'University of Exeter'
            or 'geography'

        Raises
        ------
        TypeError
            If table or name are not of type str.

        Returns
        -------
        None
        """

        _check_type(table, str)
        _check_type(name, str)





    def process_item(self, item, spider):
        return item

    # Find function to
