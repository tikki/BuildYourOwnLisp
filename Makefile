# Config.

EPUB_TARGET:=BuildYourOwnLisp.epub

CONVERT_BIN:=convert
JPEG_BIN:=jpegtran
PANDOC_BIN:=pandoc
PYTHON_BIN:=python
TEMP_DIR:=.intermediate

# EPUB sources.

METADATA:=metadata.yaml
HTML_SOURCES:=\
	splash.html \
	$(wildcard chapter?_*.html) \
	$(wildcard chapter??_*.html) \
	appendix_a_hand_rolled_parser.html \
	faq.html \
	credits.html
CSS_SOURCES:=\
	static/css/bootstrap.min.css \
	static/css/code.css
IMG_SOURCES:=$(shell grep -ohE 'static/img/[^.]+.png' *.html | sort | uniq)

PREPARED_HTML_SOURCES:=$(addprefix $(TEMP_DIR)/,$(HTML_SOURCES))
PREPARED_IMG_SOURCES:=$(addprefix $(TEMP_DIR)/,$(IMG_SOURCES:.png=.jpg))

# Make targets.

.PHONY: all clean epub
.INTERMEDIATE: $(PREPARED_HTML_SOURCES) $(PREPARED_IMG_SOURCES)

all: epub

clean:
	rm -rf $(TEMP_DIR)
	rm -f $(EPUB_TARGET)

epub: $(EPUB_TARGET)

# Recipes.

$(TEMP_DIR)/%.html: %.html
	mkdir -p $(@D)
	$(PYTHON_BIN) html-resolve-references.py $< <$< \
		| sed -Ee 's#([^a-zA-Z./])/?(static/)#\1\2#g' \
		-e 's/(href="[^/".#]+)([^".]*")/\1.html\2/g' \
		-e 's#(static/img/[^.]+)\.png#$(TEMP_DIR)/\1.jpg#g' \
		-e 's/class="panel-collapse collapse"//g' \
		>$@

$(TEMP_DIR)/static/img/%.jpg: static/img/%.png
	mkdir -p $(@D)
	$(CONVERT_BIN) $< -quality 80 jpg:- \
		| $(JPEG_BIN) > $@

$(EPUB_TARGET): $(PREPARED_HTML_SOURCES) | $(PREPARED_IMG_SOURCES) $(CSS_SOURCES) $(METADATA)
	$(PANDOC_BIN) -f html -t json $^ \
		| $(PYTHON_BIN) pandoc-filter-nav.py epub3 \
		| $(PANDOC_BIN) -f json -t epub3 -o $@ \
		--toc-depth 1 \
		--metadata-file $(METADATA) \
		$(foreach css,$(CSS_SOURCES),--css $(css))
