import scrapy
from recipe_recommender.items import ArticleItem


class DaniaMiesneSpider(scrapy.Spider):
    name = "dania_miesne"
    allowed_domains = ["aniagotuje.pl"]
    start_urls = [
        "https://aniagotuje.pl/przepisy/dania-miesne"
    ]

    visited_urls = set()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.recipe_count = 0  # <-- counter

    def parse(self, response):

        subcategory_links = response.css(
            'a[href^="/przepisy/"]::attr(href)'
        ).getall()

        subcategory_links = list(set(subcategory_links))

        for link in subcategory_links:
            if link != "/przepisy/dania-miesne":
                yield response.follow(link, callback=self.parse_category)

        yield from self.parse_category(response)

    def parse_category(self, response):

        recipe_links = response.css(
            'a[href^="/przepis/"]::attr(href)'
        ).getall()

        for link in recipe_links:
            full_url = response.urljoin(link)

            if full_url not in self.visited_urls:
                self.visited_urls.add(full_url)
                yield response.follow(full_url, callback=self.parse_recipe)

        next_page = response.css(
            'a[rel="next"]::attr(href)'
        ).get()

        if next_page:
            yield response.follow(next_page, callback=self.parse_category)

    def parse_recipe(self, response):

        self.recipe_count += 1  # <-- increase counter

        item = ArticleItem()

        item["recipe_index"] = self.recipe_count  # <-- assign index
        item["title"] = response.css("title::text").get()
        item["url"] = response.url

        item["keywords"] = response.css(
            'meta[name="keywords"]::attr(content)'
        ).get()

        item["og_description"] = response.css(
            'meta[property="og:description"]::attr(content)'
        ).get()

        item["og_image"] = response.css(
            'meta[property="og:image"]::attr(content)'
        ).get()

        ingredients = response.css(
            "ul.recipe-ing-list span.ingredient::text"
        ).getall()

        item["ingredients"] = [
            ing.strip() for ing in ingredients if ing.strip()
        ]

        step_names = response.css("div.step-name")
        step_texts = response.css("div.step-text")

        steps = []

        for name, text in zip(step_names, step_texts):
            step_title = name.css("span::text").get()
            if not step_title:
                step_title = name.css("::text").get()

            step_description = " ".join(
                text.css("::text").getall()
            ).strip()

            step_image = text.css("img::attr(src)").get()

            steps.append({
                "title": step_title.strip() if step_title else None,
                "description": step_description,
                "image": step_image
            })

        item["steps"] = steps
        item["step_count"] = len(steps)

        tags = response.css(
            "div.post-tags a::text"
        ).getall()

        item["tags"] = [
            tag.strip() for tag in tags if tag.strip()
        ]

        breadcrumbs = response.css("div.breadcrumbs a::text").getall()
        item["category"] = breadcrumbs[-1] if breadcrumbs else None

        yield item

    def closed(self, reason):
        print("\n" + "="*50)
        print(f"Total recipes scraped: {self.recipe_count}")
        print("="*50 + "\n")