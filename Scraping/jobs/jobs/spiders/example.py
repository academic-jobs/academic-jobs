# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import Rule
from re import sub
from dateutil.parser import parse
import datetime
import traceback

# Things to remember:
# Day a job expires or closes it becomes inactive
# Jobs offered over time + REF score + equipment = prosperity score

class JobsItem(scrapy.Item):
    # define the fields for your item here like:
    active = scrapy.Field()
    closes = scrapy.Field()
    contract_type = scrapy.Field()
    details = scrapy.Field()

    funding_amount = scrapy.Field()
    funding_for = scrapy.Field()
    job_ref = scrapy.Field()
    # job_type is not from the details box
    job_type = scrapy.Field()
    hours = scrapy.Field()
    location = scrapy.Field()
    main_subject = scrapy.Field()
    placed_on = scrapy.Field()
    qualification_type = scrapy.Field()

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
        try:
            item['title'] = response.xpath('//h1/text()').extract()[0]
            item['university'] = response.xpath('//h3//strong/text()').extract()[0]
            item['url'] = response.url
            duplicates = {'closes_on':'closes',
                          'expires':'closes',
                          'reference':'job_ref'}
            to_date = ['closes', 'placed_on']
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
                i_lower = i.lower()
                remove = sub('\s+', '_', i_lower)
                remove = remove.replace(":", '')
                if remove in duplicates:
                    remove = duplicates[remove]
                if remove in to_date:
                    # Parse this to make it a datetime
                    d = parse(answers[heads.index(i)])
                    # take the answer and make it a string format that mySQL will
                    # recognise 'YYYY-MM-DD'
                    answers[heads.index(i)] = d.strftime('%Y-%m-%d')
                headings.append(remove)

            # Make each heading the key to item and the answers the values

            for i in range(len(headings)):
                item[headings[i]] = answers[i]

            item['text'] = "\n".join(response.xpath('//p/text()').extract())
            boxes = response.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "j-nav-pill-box__link--label", " " ))]/text()').extract()
            item['job_type'] = boxes[0]
            item['main_subject'] = boxes[1]
            item['subject_area']= ",".join(boxes[2:])
            # MySQL uses tiny int so it can either be zero or 1
            # this means any bool (like active) needs to be zero or 1.
            item['active'] = 1
        except Exception:
            traceback.print_exc()
            return None

        return item
