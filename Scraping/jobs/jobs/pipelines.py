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
        self.uni_update = False
        self.sub_update = False
        get_unis_subs(unis = True, subs = True)

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
                                  charset = 'utf8mb4',
                                  autocommit = True)
        return connection

    def get_unis_subs(self, unis = False, subs = False):
        """Gets a dict of unique universities using self.connection

        Parameters
        ----------
        unis: bool (default: False)
            Whether to get unique list of univeristy names and ids.
        subs: bool (default: False)
            Whether to get unique list of main subject areas and ids.
        """
        if unis:
            try:
                with self.connection.cursor() as cursor:
                    # query the jobs table, getting the lowercase uni_name
                    sql = "SELECT LOWER(`uni_name`), `id` FROM `university`"
                    cursor.execute(sql)
                    t = cursor.fetchall()
                    # puts the items fetched into a dict with the key being
                    # uni_name and the value being the id
                    self.dict_of_unis = {item[0]: item[1] for item in t}
            except:
                print("Oops. Either the connection is bad, or your sql didn't "
                      "work", sys.exc_info()[0])
        else:
            if subs == False:
                raise ValueError("You should choose at least one of unis "
                                 "or subs")
        if subs:
            try:
                with self.connection.cursor() as cursor:
                    # query the jobs table, getting the lowercase uni_name
                    sql = "SELECT LOWER(`main_sub`), `id` FROM `subject`"
                    cursor.execute(sql)
                    t = cursor.fetchall()
                    # puts the items fetched into a dict with the key being
                    # uni_name and the value being the id
                    self.dict_of_subs = {item[0]: item[1] for item in t}
            except:
                print("Oops. Either the connection is bad, or your sql didn't "
                      "work", sys.exc_info()[0])
        else:
            if unis == False:
                raise ValueError("You should choose at least one of unis "
                                 "or subs")

    def insert_uni_sub(self, table, name):
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
        ValueError
            If the table to insert into is not university or subject.

        Returns
        -------
        None
        """

        _check_type(table, str)
        _check_type(name, str)

        # Find length of table and determine next id. This is assuming that
        # dict_of_unis and dict_of_subs is up-to-date.
        if table == 'university':
            length = len(self.dict_of_unis)
        elif table == 'subject':
            length = len(self.dict_of_subs)
        else:
            raise ValueError("This function doesn't insert into tables "
                             "other than university or subject. Please "
                             "use insert_item instead")
        item_id = length + 1

        try:
            with self.connection.cursor() as cursor:
                # first, second, third and fourth %s are table name,
                # id, col2, item_id, name
                col1 = 'id'
                if table == 'university':
                    col2 = 'uni_name'
                else:
                    col2 = 'main_sub'

                cursor.execute("INSERT INTO %s (%s, %s) VALUES(%d, '%s')",
                               (table, col1, col2, item_id, name))
        except:
            print("Oops. Either the connection is bad, or your sql didn't "
                  "work, or you don't have the right "
                  "permissions", sys.exc_info()[0])

        if table == 'university':
            self.uni_update = True
        elif table == 'subject':
            self.sub_update = True

    def process_item(self, item, spider):
        active = item['active']
        closes = item['active']
        closes_on = item['active']
        contract_type = item['active']
        details = item['active']
        expires = item['active']
        funding_amount = item['active']
        funding_for = item['active']
        job_ref = item['active']
        # job_type is not from the details box
        job_type = item['active']
        hours = item['active']

        location = item['active']
        placed_on = item['active']
        qualification_type = item['active']
        reference = item['active']

        salary = item['active']
        subject_area = item['active']
        text = item['active']
        title = item['active']
        university = item['active']
        url = item['active']
        return item

    # Find function to
