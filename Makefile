# Config.

EPUB_TARGET:=BuildYourOwnLisp.epub

PANDOC_BIN:=pandoc
TEMP_DIR:=.intermediate

# EPUB sources.

COVER_IMAGE:=static/book/cover_front.jpg
METADATA:=metadata.yaml
SOURCES:=\
	splash.html \
	contents.html \
	$(wildcard chapter?_*.html) \
	$(wildcard chapter??_*.html) \
	appendix_a_hand_rolled_parser.html \
	faq.html \
	credits.html
CSS_SOURCES:=\
	static/css/bootstrap.min.css \
	static/css/code.css

PREPARED_SOURCES:=$(addprefix $(TEMP_DIR)/,$(SOURCES))

# Make targets.

.PHONY: all clean epub
.INTERMEDIATE: $(PREPARED_SOURCES)

all: epub

clean:
	rm -rf $(TEMP_DIR)
	rm -f $(EPUB_TARGET)

epub: $(EPUB_TARGET)

# Recipes.

$(TEMP_DIR)/%.html: %.html
	mkdir -p $(@D)
	sed -E 's#([^a-zA-Z./])/?(static/)#\1\2#g' $< >$@

$(EPUB_TARGET): $(PREPARED_SOURCES) | $(COVER_IMAGE) $(CSS_SOURCES) $(METADATA)
	$(PANDOC_BIN) -f html -t epub3 -o $@ \
		--epub-cover-image $(COVER_IMAGE) \
		--metadata-file $(METADATA) \
		$(foreach css,$(CSS_SOURCES),--css $(css)) \
		$^
