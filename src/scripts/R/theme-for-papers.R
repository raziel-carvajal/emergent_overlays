library(grid)
library(ggthemes)

theme0 <- function(base_size=10, base_family="Helvetica") {
  (theme_foundation(base_size=base_size, base_family=base_family)
   + theme(
			 plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0.5),
	     text = element_text(),
	     panel.background = element_rect(colour = NA),
	     plot.background = element_rect(colour = NA),
	     panel.border = element_rect(colour = NA),
	     axis.title = element_text(size = rel(1)),
			 # axis.text.y = element_blank(),
			 axis.ticks.x = element_blank(),
			 axis.text.x = element_blank(),
			 # axis.line.x = element_blank(),
	     axis.title.y = element_text(angle=90,vjust =2),
			 # axis.title.x = element_text(vjust  = -0.2),
			 axis.title.x = element_blank(),
	     axis.text = element_text(size = rel(1)),
	     axis.line = element_line(colour="#000000"),
	     axis.ticks = element_line(),
	     panel.grid.major = element_line(colour="#f0f0f0"),
	     panel.grid.minor = element_blank(),
	     legend.key = element_rect(colour = NA),
 	     legend.position = "none",
	     # legend.position = "top",
	     legend.direction = "horizontal",
	     legend.key.size= unit(0.8, "cm"),
	     legend.margin = unit(1, "cm"),
			 legend.title = element_blank(),
	     # legend.title = element_text(face="italic"),
	     plot.margin=unit(c(1,5,5,5),"mm"),
	     strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
	     # strip.text = element_text(face="bold")
     )
	 )
}

theme1 <- function(base_size=10, base_family="Helvetica") {
  (theme_foundation(base_size=base_size, base_family=base_family)
   + theme(
			 plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0.5),
	     text = element_text(),
	     panel.background = element_rect(colour = NA),
	     plot.background = element_rect(colour = NA),
	     panel.border = element_rect(colour = NA),
	     axis.title = element_text(size = rel(1)),
			 axis.ticks.x = element_blank(),
			 axis.text.x = element_blank(),
			 # axis.line.x = element_blank(),
	     axis.title.y = element_text(angle=90,vjust =2),
			 # axis.title.x = element_text(vjust  = -0.2),
			 axis.title.x = element_blank(),
	     axis.text = element_text(size = rel(1)),
	     axis.line = element_line(colour="#000000"),
	     axis.ticks = element_line(),
	     panel.grid.major = element_line(colour="#f0f0f0"),
	     panel.grid.minor = element_blank(),
	     legend.key = element_rect(colour = NA),
 	     legend.position = "none",
	     # legend.position = "bottom",
	     legend.direction = "horizontal",
	     legend.key.size= unit(0.5, "cm"),
	     legend.margin = unit(1, "cm"),
			 legend.title = element_blank(),
	     # legend.title = element_text(face="italic"),
	     plot.margin=unit(c(-5,5,5,5),"mm"),
	     strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
	     # strip.text = element_text(face="bold")
     )
	 )
}

theme2 <- function(base_size=10, base_family="Helvetica") {
  (theme_foundation(base_size=base_size, base_family=base_family)
   + theme(
			 plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0.5),
	     text = element_text(),
	     panel.background = element_rect(colour = NA),
	     plot.background = element_rect(colour = NA),
	     panel.border = element_rect(colour = NA),
	     axis.title = element_text(size = rel(1)),
			 # axis.text.y = element_blank(),
			 # axis.ticks.y=element_blank(),
			 # axis.line.y=element_blank(),
	     axis.title.y = element_text(angle=90,vjust =2),
			 axis.title.x = element_text(vjust  = -0.2),
			 # axis.title.x = element_blank(),
	     axis.text = element_text(size = rel(1)),
	     axis.line = element_line(colour="#000000"),
	     axis.ticks = element_line(),
	     panel.grid.major = element_line(colour="#f0f0f0"),
	     panel.grid.minor = element_blank(),
	     legend.key = element_rect(colour = NA),
 	     legend.position = "none",
	     # legend.position = "bottom",
	     legend.direction = "horizontal",
	     legend.key.size= unit(0.5, "cm"),
	     legend.margin = unit(1, "cm"),
			 legend.title = element_blank(),
	     # legend.title = element_text(face="italic"),
	     plot.margin=unit(c(-5,5,5,5),"mm"),
	     strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
	     # strip.text = element_text(face="bold")
     )
	 )
}

scale_fill_Publication <- function(...){
      library(scales)
      discrete_scale("fill","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")), ...)

}

scale_colour_Publication <- function(...){
      library(scales)
      discrete_scale("colour","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")), ...)
}

scale_gray_colour_Publication <- function(...){
      library(scales)
      discrete_scale("colour","Publication",manual_pal(values = c("#cccccc", "#999999", "#333333")), ...)
}
