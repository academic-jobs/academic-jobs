# -*- coding: utf-8 -*-


from pymysql import cursors, connect
import traceback
from itertools import chain

class REFPipeline(object):

    def __init__(self):
        # Open the connection to the database and leave open
        self.connection = self.open_connection()
        self.uni_update = False
        self.sub_update = False
        self.ref_update = False
        self.get_unis_subs(unis=True, subs=True, ref_dept=True)

    def _check_type(self, ar, data_types):
        """Raises an error if ar is not of the type given"""
        if not type(ar) in data_types:
            raise TypeError("Only {} types are supported. Got {}.".format(data_types,
                                                                          type(ar)))

    def open_connection(self):
        """Opens a connection to the database and keeps it open."""
        connection = connect(host='localhost',
                             user = 'olivia',
                             password = 'owilsoli',
                             db = 'academic',
                             charset = 'utf8mb4',
                             autocommit = True)
        return connection

    def get_unis_subs(self, unis=False, subs=False, ref_dept=False):
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
            if ref_dept:
                try:
                    with self.connection.cursor() as cursor:
                        # query the jobs table, getting the lowercase uni_name
                        sql = "SELECT LOWER(`ref_dept_name`), `id` FROM `ref_dept`"
                        cursor.execute(sql)
                        t = cursor.fetchall()
                        # puts the items fetched into a dict with the key being
                        # uni_name and the value being the id
                        self.dict_of_ref = {item[0]: item[1] for item in t}
                except Exception:
                    print("Oops. Either the connection is bad, or your sql didn't "
                          "work, or you don't have the right "
                          "permissions")
                    traceback.print_exc()
                    print(sql)


    def insert_uni_sub(self, table, name):
        """Inserts a new item into the relevant table, creating the SQL required.

        This should only be used for the universities, subject or ref_dept
        tables. This uses the fact that each item in these tables should be
        unique and therefore the length of the unique list is also the number
        of items in the table.

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
        elif table == 'ref_dept':
            length == len(self.dict_of_ref)
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
                else table = 'ref_dept':
                    col2 = 'ref_dept_name'

                sql = "INSERT INTO %s (%s) VALUES('%s')" % (table, col2, self.connection.escape_string(name))
                cursor.execute(sql)

                row_id = cursor.lastrowid
        except Exception:
            print("Oops. Either the connection is bad, or your sql didn't "
                  "work, or you don't have the right "
                  "permissions")
            traceback.print_exc()
            print("INSERT INTO %s (%s) VALUES('%s')" % (table, col2, name))
            return None

        if table == 'university':
            self.uni_update = True
        elif table == 'ref_dept':
            self.ref_update = True

        return row_id

    def process_item(self, item):
        # item is a single item from the csv.

        item_dict = dict(item)

        # Check if the item is in dict_of_unis
        if item_dict['university'].lower() in self.dict_of_unis:
            uni_id = self.dict_of_unis[item_dict['university'].lower()]
        else:
            uni_id = self.insert_uni_sub('university', item_dict['university'])

        item_dict['uni_id'] = str(uni_id)

        self.get_unis_subs(self.uni_update)

        diff_items = ['university', ref_dept]

        # delete diff items from dict
        for d in diff_items:
            del new_dict[d]

        col = tuple(i[0] for i in item_dict.items())
        col = tuple(str(i) for i in col)
        col = "(%s)" % (",".join(col))

        val = [self.connection.escape_string(i[1]) for i in item_dict.items()]
        val = tuple(val)

        val = repr(val)
        val = val.replace("u'", "'")
        val = val.replace('u"', '"')

        try:
            with self.connection.cursor() as cursor:
                sql = "INSERT INTO jobs %s VALUES %s" % (col,val)
                cursor.execute(sql)
        except Exception:
            print("Oops. Either the connection is bad, or your sql didn't "
                  "work, or you don't have the right "
                  "permissions")
            traceback.print_exc()
            print(sql)

        return item

    def run(self):
        # reads csv in line by line and then does all the other things
        # and checks against
        

if __name__ == '__main__':
    ref_pipeline = REFPipeline()
    ref_pipline.run()
