# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import Rule
from re import sub

# Things to remember:
# Day a job expires or closes it becomes inactive
# Jobs offered over time + REF score + equipment = prosperity score

class JobsItem(scrapy.Item):
    # define the fields for your item here like:
    closes = scrapy.Field()
    closes_on = scrapy.Field()
    contract_type = scrapy.Field()
    details = scrapy.Field()
    expires = scrapy.Field()
    funding_amount = scrapy.Field()
    funding_for = scrapy.Field()
    job_ref = scrapy.Field()
    # job_type is not from the details box
    job_type = scrapy.Field()
    hours = scrapy.Field()

    location = scrapy.Field()
    placed_on = scrapy.Field()
    qualification_type = scrapy.Field()
    reference = scrapy.Field()

    salary = scrapy.Field()
    subject_area = scrapy.Field()
    text = scrapy.Field()
    title = scrapy.Field()
    university = scrapy.Field()
    url = scrapy.Field()

class MySpider(scrapy.spiders.CrawlSpider):
    name = "acad_jobs"

    allowed_domains = ['jobs.ac.uk']

    start_urls = ['http://www.jobs.ac.uk/']
    rules = (
            Rule(LinkExtractor(allow=('/jobs/', ))),
            Rule(LinkExtractor(allow=('/search/',))),

            # Extract links matching 'item.php' and parse them with the spider's
            # method parse_item
            Rule(LinkExtractor(allow=('/job/', )), callback='parse_item'),
            )

    def parse_item(self, response):

        item = JobsItem()
        item['title'] = response.xpath('//h1/text()').extract()
        item['university'] = response.xpath('//h3//strong/text()').extract()
        item['url'] = response.url
        heads = response.xpath('//td[@class="detail-heading"]/text()').extract()
        ans = response.xpath('//td[not(@class="detail-heading")]/text()').extract()
        answers = []
        headings = []

        # Strip the answers list of whitespace and put spaces in between
        for i in ans:
             remove = sub('\s+', ' ', i)
             answers.append(remove.strip())

        # Strip headings of all spacing, replacing with nothing
        for i in heads:
            i = i.lower()
            remove = sub('\s+', '_', i)
            headings.append(remove.replace(":", ''))

        # Make each heading the key to item and the answers the values

        for i in range(len(headings)):
            item[headings[i]] = answers[i]

        item['text'] = response.xpath('//p/text()').extract()
        boxes = response.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "j-nav-pill-box__link--label", " " ))]/text()').extract()
        item['job_type'] = boxes[0]
        item['subject_area']= boxes[1:]



        return item
