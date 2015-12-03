from scrapy.exceptions import IgnoreRequest
from pymysql import cursors, connect
from itertools import chain

# This class doesn't inherit from any base class - there are ones already created
# for custom uses like cookies etc. but no base class!

class MyCustomDownloaderMiddleware:

    def __init__(self):
        self.spider = "acad_jobs"
        self.list_of_urls = self.get_urls()

    def get_urls(self):
        # Make pymysql connection
        connection = connect(host = 'localhost',
                             user = 'olivia',
                             password = 'owilsoli',
                             db = 'academic',
                             charset = 'utf8mb4')
        try:
            with connection.cursor() as cursor:
                # query the jobs table
                sql = "SELECT DISTINCT `url` FROM `jobs`"
                cursor.execute(sql)
                list_of_urls = cursor.fetchall()
                list_of_urls = list(chain.from_iterable(list_of_urls))
        finally:
            connection.close()
        return list_of_urls if list_of_urls else None

    def process_request(self, request, spider):
        if request.url in self.list_of_urls:
            # raising the exception will then be handed to the process exception
            # handler. If none of the exceptions are handled then it is ignored
            # and not handled (the response is never downloaded).
            raise IgnoreRequest("This url is already in the database")
        else:
            # None means that scrapy will continue processing the request
            # executing other middlewares until the downloader handler is
            # called and the response is downloaded.
            return None
