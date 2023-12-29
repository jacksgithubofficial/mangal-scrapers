-------------------------------------
-- @name    allporncomic 
-- @url     https://allporncomic.com/
-- @author  johnjames 
-- @license MIT
-------------------------------------


---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Html = require("html")
Headless = require('headless')
Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()
Base = "https://allporncomic.com/"
Delay = 1 -- seconds
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	query = string.gsub(query, "’s", "")
    query = string.gsub(query, "'s", "")
    local url = Base .. "/?s=" .. query .. "&post_type=wp-manga"
    Page:navigate(url)
    Time.sleep(Delay)

    local mangas = {}
	for _, v in ipairs(Page:elements(".tab-content-wrap > .c-tabs-item .tab-thumb > a")) do
        local manga = { url = v:attribute('href'), name = v:attribute('title'), translator = "AllPornComic" }
        table.insert(mangas, manga)
    end

    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	Page:navigate(mangaURL)
	Time.sleep(Delay)

	local manga_summary = Page:element(".summary__content"):text()
	local manga_author = Page:element(".artist-content > a"):text()
	local manga_genres = Page:element(".genres-content"):text()

	local chapters = {}
	for _, v in ipairs(Page:elements(".wp-manga-chapter > a")) do
		local chapter = { url = v:attribute('href'), name = v:text(), volume = 1, manga_summary = manga_summary, manga_author = manga_author, manga_genres = manga_genres }
		table.insert(chapters, chapter)
	end

	-- reverse the table
	local n = #chapters
	for i=1, math.floor(n/2) do
		chapters[i], chapters[n-i+1] = chapters[n-i+1], chapters[i]
	end

	-- add volume number to chapters
	local volume = 1
	for i, v in ipairs(chapters) do
		v.volume = "" .. volume
		volume = volume + 1
	end

	return chapters	
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
	Page:navigate(chapterURL)
	Time.sleep(Delay)

	-- get all images from .page-break div
	local i = 1
	local pages = {}
	for _, v in ipairs(Page:elements(".page-break > img")) do
		local page = { url = string.gsub(v:attribute('data-src'), "%s+", ""), index = i }
		table.insert(pages, page)
		i = i + 1
	end

	return pages
end

--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
