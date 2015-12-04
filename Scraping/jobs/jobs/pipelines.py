# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
from pymysql import cursors, connect
import traceback
from itertools import chain

class JobsPipeline(object):

    def __init__(self):
        # Open the connection to the database and leave open
        self.connection = self.open_connection()
        self.uni_update = False
        self.sub_update = False
        self.get_unis_subs(unis = True, subs = True)

    def _check_type(self, ar, data_types):
        """Raises an error if ar is not of the type given"""
        if not type(ar) in data_types:
            raise TypeError("Only {} types are supported. Got {}.".format(data_types,
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
        if unis == False and subs == False:
            return
        else:
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
                except Exception:
                    print("Oops. Either the connection is bad, or your sql didn't "
                          "work, or you don't have the right "
                          "permissions")
                    traceback.print_exc()
                    print(sql)
            # There is now no else statement because it maybe that I don't want
            # to call it at all if there was no updating
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
                except Exception:
                    print("Oops. Either the connection is bad, or your sql didn't "
                          "work, or you don't have the right "
                          "permissions")
                    traceback.print_exc()
                    print(sql)


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

        self._check_type(table, [str, unicode])
        self._check_type(name, [str, unicode])

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

        try:
            with self.connection.cursor() as cursor:
                # first, second, third and fourth %s are table name,
                # id, col2, item_id, name
                if table == 'university':
                    col2 = 'uni_name'
                else:
                    col2 = 'main_sub'

                sql = "INSERT INTO %s (%s) VALUES('%s')" % (table, col2, name)

                cursor.execute(sql)

                row_id = cursor.lastrowid
        except Exception:
            print("Oops. Either the connection is bad, or your sql didn't "
                  "work, or you don't have the right "
                  "permissions")
            traceback.print_exc()
            print(sql)
            return None

        if table == 'university':
            self.uni_update = True
        elif table == 'subject':
            self.sub_update = True

        return row_id

    def process_item(self, item, spider):
        item_to_db = {'active':'active',
                      'closes':'closes',
                      'contract_type':'contract_type',
                      'details':'detail',
                      'funding_amount':'funding_amount',
                      'funding_for':'funding_for',
                      'job_ref':'job_ref',
                      'job_type':'job_type',
                      'hours':'job_hours',
                      'location':'location',
                      'main_subject':'main_subject',
                      'placed_on':'placed_on',
                      'qualification_type':'qualification_type',
                      'salary':'salary',
                      'subject_area':'sub_list',
                      'text':'text',
                      'title':'title',
                      'university':'university',
                      'url':'url'}

        diff_items = ['university', 'main_subject']
        item_dict = dict(item)
        new_dict = {}

        for k, v in item_dict.iteritems():
            new_dict[item_to_db[k]] = v

        # Check if the item is in dict_of_unis
        if item_dict['university'].lower() in self.dict_of_unis:
            uni_id = self.dict_of_unis[item_dict['university'].lower()]
        else:
            uni_id = self.insert_uni_sub('university', item_dict['university'])

        new_dict['uni_id'] = uni_id

        # Check if the item is in dict_of_subs
        if item_dict['main_subject'].lower() in self.dict_of_subs:
            main_sub_id = self.dict_of_subs[item_dict['main_subject'].lower()]
        else:
            main_sub_id = self.insert_uni_sub('subject', item_dict['main_subject'])

        new_dict['main_sub_id'] = main_sub_id

        self.get_unis_subs(self.uni_update, self.sub_update)

        # delete diff items from dict
        for d in diff_items:
            del new_dict[d]

        col = tuple(i[0] for i in new_dict.items())
        col = tuple(str(i) for i in col)
        col = "(%s)" % (",".join(col))
        val = tuple(i[1] for i in new_dict.items())

        try:
            with self.connection.cursor() as cursor:
                sql = "INSERT INTO jobs %s VALUES %s" % (col, repr(val))
                cursor.execute(sql)
        except Exception:
            print("Oops. Either the connection is bad, or your sql didn't "
                  "work, or you don't have the right "
                  "permissions")
            traceback.print_exc()
            print(sql)

        return item

    def close_spider(self, spider):
        self.connection.close()
