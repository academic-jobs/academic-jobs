# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class JobsItem(scrapy.Item):
    # define the fields for your item here like:
    title = scrapy.Field()
    university = scrapy.Field()
    url = scrapy.Field()
    details = scrapy.Field()
    text = scrapy.Field()

    pass

class MySpider(scrapy.Spider):
    name = "acad_jobs"

    allowed_domains = ['jobs.ac.uk']

    start_urls = ['http://www.jobs.ac.uk/']
    rules = (
            Rule(LinkExtractor(allow=('/jobs/', ),  )),
            Rule(LinkExtractor(allow=('/search/',),  )),

            # Extract links matching 'item.php' and parse them with the spider's
            # method parse_item
            Rule(LinkExtractor(allow=('job/', )), callback='parse_item'),
            )

    def parse_item(self, response):
        self.logger.info('Say something here?', response.url)

        item = scrapy.Item()
        item['title'] = response.xpath('//h1/text()').extract().text()
        item['university'] = response.xpath('//strong | //h1/text()').extract()
        item['url'] = response.url
        item['details'] = response.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "advert-details-box", " " ))]/text()').extract()
        item['text'] = response.xpath('//p/text()').extract()
        return item
