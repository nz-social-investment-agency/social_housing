###############################################
####
#### Title: ggplot2 theme functions for the SIU
#### Author: Conrad MacCormick
#### Date:10 November 2016
####
#### Directions: Load ggplot2 and compile both 
#### functions. See testing code at the botom
#### for an example.
#### 
###############################################

# library(ggplot2)

####theme_siu####
theme_siu <- function(base_size = 12, base_family = "") 
{
  half_line <- base_size/2
  theme_grey(base_size = base_size, base_family = base_family) %+replace% 
    theme(
      axis.text = element_text(colour = "#315259", family = 'Century Gothic', size = rel(0.8)),
      axis.title = element_text(colour = "#588D97", family = 'Century Gothic'),
      axis.ticks = element_line(colour = "black"), 
      legend.key = element_rect(colour = NA),
      legend.title = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(color = "#588D97", family = 'Century Gothic', size = 15, 
                                margin = margin(b = half_line * 1.2)),
      plot.margin = margin(half_line, half_line, half_line, half_line)
    )
}

#Put in ggplot2 environment to inherit ggplot2 functionality
environment(theme_siu) <- asNamespace("ggplot2")

###############################################################################################

####scale_colour_siu#####
scale_colour_siu <- function(..., values) {
  manual_scale("colour", values = c("#588D97", "#F47C20", "#315259", "#414258", "#262638"), ...)
}

#Put in ggplot2 environment to inherit ggplot2 functionality
environment(scale_colour_siu) <- asNamespace("ggplot2")

###############################################################################################

####scale_fill_siu#####
scale_fill_siu <- function(..., values) {
  manual_scale("fill", values = c("#588D97", "#F47C20", "#315259", "#414258", "#262638"), ...)
}

#Put in ggplot2 environment to inherit ggplot2 functionality
environment(scale_fill_siu) <- asNamespace("ggplot2")

###############################################################################################

# some hard coded values (used in ps weighting and balancing)
siuDarkBlue <- rgb(35, 35, 56, maxColorValue = 255)
siuDarkBlue2 <- rgb(65, 66, 88, maxColorValue = 255)
siuGreen <- rgb(8, 141, 151, maxColorValue = 255)
siuGreen2 <- rgb(49, 82, 89, maxColorValue = 255)
siuOrange <- rgb(244, 124, 32, maxColorValue = 255)
siuGrey <- rgb(189, 186, 192, maxColorValue = 255)
siuGrey2 <- rgb(209, 211, 212, maxColorValue = 255)

###############################################################################################

####For testing...

# ggplot(mtcars, aes(mpg, wt, colour = as.factor(cyl))) +
#   geom_point() +
#   ggtitle("Fuel Economy Data (1999 and 2008)") +
#   theme_siu() +
#   scale_colour_siu()
# ggplot(iris, aes(Petal.Length, Petal.Width, colour = Species)) +
#   geom_point() +
#   ggtitle("Iris Data") +
#   theme_siu() +
#   scale_colour_siu()
# ggplot(diamonds, aes(price)) +
#   geom_histogram(aes(fill = cut)) +
#   ggtitle("Diamonds Data") +
#   theme_siu() +
#   scale_fill_siu()
