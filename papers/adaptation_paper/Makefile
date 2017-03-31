FILE=main
FINAL=main-submission-

MAKEFLAGS=	--no-print-directory

# GNUPlot source files
GPSOURCE= 

# EPS files included
EPSSOURCE= 

# BIB files included
BIBS= \
	references.bib

# .tex file includes or inputs
TEXIN= \
	introduction.tex \
	related.tex \
	conclusion.tex

# other file dependencies
DEPS= Makefile \
	main.sty

# Output assumed to depend on $FILE, $TEXIN, $GPSOURCE, $EPSSOURCE, $BIBS and $DEPS

GRAPHICSSOURCE= ${GPSOURCE} ${EPSSOURCE} 

EPSGRAPHICS= $(GPSOURCE:.gp=.eps) ${EPSSOURCE}

PDFGRAPHICS=$(EPSGRAPHICS:.eps=.pdf)

GNUPLOT= gnuplot 

default: pdf

${FINAL}.pdf ${FINAL}.ps.gz final: ${FILE}.dvi
	${MAKE} bib
	pdflatex --interaction nonstopmode ${FILE}

tags etags: TAGS

TAGS: ${FILE}.tex ${TEXIN} ${DEPS}
	etags ${FILE}.tex ${TEXIN} ${DEPS}

graphics: epsgraphics pdfgraphics

epsgraphics: ${EPSGRAPHICS}

pdfgraphics: ${PDFGRAPHICS}

dvi: $(FILE).dvi 

# $(FILE).dvi ${FILE}.aux: ${FILE}.tex ${DEPS} ${EPSGRAPHICS}
# 	rm -f ${FILE}.ps ${FILE}.ps.gz ${FILE}.pdf
# 	latex $(FILE)
# 	latex $(FILE)

pdf: $(FILE).pdf 
	${MAKE} bib
	pdflatex --interaction nonstopmode ${FILE}

$(FILE).pdf: ${FILE}.tex ${TEXIN} ${DEPS} ${PDFGRAPHICS}
	pdflatex --interaction nonstopmode $(FILE)

force: default bib
	rm -f ${FILE}.dvi ${FILE}.pdf; ${MAKE} default

${FILE}.bbl: ${FILE}.aux ${BIBS} 
		BIBINPUTS=tmp/:$$BIBINPUTS bibtex $(FILE)
		sed -e 's/%//g' < $(FILE).bbl > $(FILE).bbl~
		mv $(FILE).bbl~ $(FILE).bbl

clean::
	rm -rf tmp/

bib: $(FILE).bbl 

#figs:
#		( cd figs; $(MAKE) )
clean::
		/bin/rm -f f *~ *.bak *.aux *.log *.toc *.lof *.dvi *.bbl *.blg *.out \#* main.pdf

spotless:	clean
		/bin/rm -f *.dvi *.ps *.ps.gz main.pdf

ps: $(FILE).ps

# pdflatex: $(FILE).pdf

# $(FILE).pdf $(FILE).aux: ${FILE}.tex ${PDFGRAPHICS}
# 	pdflatex ${FILE}.tex

gz ps.gz: $(FILE).ps.gz

print lpr: $(FILE).ps
	lpr $(FILE).ps || gsprint $(FILE).ps

gv: $(FILE).ps
	gv -nopixmap $(FILE).ps

$(FILE).dvi: $(FILE).tex $(FIGS)

%.prn: %.ppt
	@echo 'You must manually create $@ from Powerpoint $^!' 2>&1; exit 1
clean::
	rm -f *.prn

%.eps: %.obj
	tgif -print -eps $^
%.eps: %.gp
	$(GNUPLOT) $^
# %.eps: %.gp dat/%.dat
#	$(GNUPLOT) $^
%.eps: %.fig
	fig2dev -L eps $^ >$@
%.eps: %.prn
	ps2epsi $^ $@
clean::
	rm -f ${EPSGRAPHICS}

%.eps: %.dia
	dia -e $@ $^
# %.eps: %.ps
#	ps2epsi $^ $@
%.eps: %.epsraw
	ps2epsi $^ $@
clean::
	rm -f *.eps

%.dvi: %.tex
	latex $^

# According to ACM instructions, '-P cmz' embeds Type 1 fonts, which
# enables later PDF generation to be of higher quality 
%.ps: %.dvi
	dvips -C a4 -P cmz $^ -o
	rm -f $@.gz
%.ps.gz: %.ps
	gzip --best $^

%.pdf: %.tex
	${MAKE} bib
	pdflatex --interaction nonstopmode ${FILE}
	pdflatex --interaction nonstopmode ${FILE}

clean::
	rm -f ${PDFGRAPHICS}

# subalgorithms
sub1.prn sub2.prn sub3.prn sub4.prn sub5.prn: subalgorithms.ppt
	@echo 'You must manually create $@ from Powerpoint $^!' 2>&1; exit 1
pdffigs.tgz: ${PDFGRAPHICS}
	tar czf pdffigs.tgz ${PDFGRAPHICS}
epsfigs.tgz: ${EPSGRAPHICS}
	tar czf epsfigs.tgz ${EPSGRAPHICS}

tgz: ${FINAL}.pdf
	dir=`basename $$PWD`; \
	tar czvf $(FILE).tgz -C .. \
	$(patsubst %,$$dir/%,\
	    ${FILE}.tex \
	    ${TEXIN} \
	    ${DEPS} \
	    ${EPSSOURCE} \
	    ${GPSOURCE} \
	    ${patsubst %,dat/%,${GPSOURCE:.gp=.dat}}\
	    ${BIBS} \
	    ${FINAL}.pdf \
	)
