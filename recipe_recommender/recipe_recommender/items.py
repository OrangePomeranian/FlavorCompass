import scrapy


class ArticleItem(scrapy.Item):

    recipe_index = scrapy.Field()

    title = scrapy.Field()
    url = scrapy.Field()

    keywords = scrapy.Field()
    og_description = scrapy.Field()
    og_image = scrapy.Field()

    ingredients = scrapy.Field()
    steps = scrapy.Field()
    step_count = scrapy.Field()

    tags = scrapy.Field()
    category = scrapy.Field()