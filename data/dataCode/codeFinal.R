library(reshape)
library(tidyr)
library(ggplot2) # ggplot
library(scales) # comma
library(grid)

setwd("~/Dropbox/- Code/- Github/employmentEducationSpatialSurvey/data/dataCode")

# Read in county-level data and US totals ####
dat = read.csv('../dataRaw/ACS_15_5YR_S2301_with_ann.csv', 
               header = T,
               stringsAsFactors = F)

# Employment vs. population ####
variables = c('GEO.id2',
              'HC03_EST_VC44',
              'HC03_EST_VC45',
              'HC03_EST_VC46',
              'HC03_EST_VC47')

# Subset only emp-pop variables ####
df = subset(dat, select = variables); rm(variables)
df = df[2:nrow(df),]

df[, c(2:ncol(df))] = sapply(df[, c(2:ncol(df))], as.numeric) # convert to numeric

summary(df)

# BRACKETS ####
# Education // less HS ####
variables = c('GEO.id2',
              'HC01_EST_VC44',
              'HC03_EST_VC44')

df = subset(dat, select = variables); rm(variables)

df = df[2:nrow(df),]

df[, c(2:ncol(df))] = sapply(df[, c(2:ncol(df))], as.numeric) # convert to numeric

df$Brackets = cut(df$HC03_EST_VC44, breaks = c(0, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 100))
df = aggregate(HC01_EST_VC44 ~ Brackets, data = df, FUN = sum)

datf = df

# Education // HS ####
variables = c('GEO.id2',
              'HC01_EST_VC45',
              'HC03_EST_VC45')

df = subset(dat, select = variables); rm(variables)

df = df[2:nrow(df),]

df[, c(2:ncol(df))] = sapply(df[, c(2:ncol(df))], as.numeric) # convert to numeric

df$Brackets = cut(df$HC03_EST_VC45, breaks = c(0, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 100))
df = aggregate(HC01_EST_VC45 ~ Brackets, data = df, FUN = sum)

datf = merge (datf, df, by.datf = 'Brackets', by.df = 'Brackets', all = T)

# Education // Somecollege ####
variables = c('GEO.id2',
              'HC01_EST_VC46',
              'HC03_EST_VC46')

df = subset(dat, select = variables); rm(variables)

df = df[2:nrow(df),]

df[, c(2:ncol(df))] = sapply(df[, c(2:ncol(df))], as.numeric) # convert to numeric

df$Brackets = cut(df$HC03_EST_VC46, breaks = c(0, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 100))
df = aggregate(HC01_EST_VC46 ~ Brackets, data = df, FUN = sum)

datf = merge (datf, df, by.datf = 'Brackets', by.df = 'Brackets', all = T)

# Education // BAorHigher ####
variables = c('GEO.id2',
              'HC01_EST_VC47',
              'HC03_EST_VC47')

df = subset(dat, select = variables); rm(variables)

df = df[2:nrow(df),]

df[, c(2:ncol(df))] = sapply(df[, c(2:ncol(df))], as.numeric) # convert to numeric

df$Brackets = cut(df$HC03_EST_VC47, breaks = c(0, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 100))
df = aggregate(HC01_EST_VC47 ~ Brackets, data = df, FUN = sum)

datf = merge (datf, df, by.datf = 'Brackets', by.df = 'Brackets', all = T)

df = datf
df = melt(df, id.vars = c('Brackets'))
colnames(df) = c('Bracket', 'Variable', 'Value')

df$Variable = gsub('HC01_EST_VC44', 
                   'Less than high school graduate', 
                   df$Variable)
df$Variable = gsub('HC01_EST_VC45', 
                   'High school graduate (includes equivalency)', 
                   df$Variable)
df$Variable = gsub('HC01_EST_VC46', 
                   "Some college or associate's degree", 
                   df$Variable)
df$Variable = gsub('HC01_EST_VC47', 
                   "Bachelor's degree or higher",
                   df$Variable)

df$Value = df$Value/10^6

df$Bracket = gsub('\\(', '', df$Bracket)
df$Bracket = gsub('\\]', '', df$Bracket)
df$Bracket = gsub('\\,', '-', df$Bracket)

write.csv(df, '../brackets.csv', row.names = F)

df$Variable = factor(df$Variable,
                     levels = c('Less than high school graduate',
                                'High school graduate (includes equivalency)',
                                "Some college or associate's degree", 
                                "Bachelor's degree or higher"))

font = "Source Sans Pro" ## set font for graph
fsize = 5.5 ## set font size for graph
footer = 35 ## font 7 = 43; font 8 = 37.5

png(file = "../dataGraphs/Figure 1. Employment-population ratio, aged 25-64, by educational attainment.png", width = 6, height = 3, units = "in", res = 600)
p <- ggplot(df, aes(Bracket, Value, fill = Variable)) +
        geom_bar(position = 'dodge', stat = 'identity') + 
        labs(x = "") +
        labs(y = "million people") + 
        scale_fill_manual(values = c('#8c510a', '#d8b365', '#5ab4ac', '#01665e' )) + 
        ggtitle('Employment-Population Ratio, Population 25 to 64 years, by County') + 
        theme_bw() + 
        theme(panel.grid.minor = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.major.y = element_line(color='#E1E1E1', linetype = 'dashed', size = .1),
              strip.background = element_blank(),
              panel.border = element_rect(color='#bdbdbd'),
              panel.spacing.y=unit(-.05, "cm"),
              legend.position = "none",
              axis.ticks = element_blank(),
              plot.title = element_text(size = fsize, family = font, face = 'bold', hjust = 0.5),
              strip.text.x = element_text(size = fsize, family = font),
              axis.text.x = element_text(size = fsize, family = font),
              axis.text.y = element_text(size = fsize, family = font),
              axis.title.x = element_text(size = fsize, family = font),
              axis.title.y = element_text(size = fsize, family = font))
p + facet_wrap(~ Variable, ncol=2, scales = "free")
grid.text('Source: U.S. Census Bureau, 2011-2015 American Community Survey 5-Year Estimates (S2301, EMPLOYMENT STATUS)',
          vjust=footer, gp = gpar(fontfamily=font, fontsize = fsize-1))
dev.off()

# SCATTER ####
variables = c('GEO.id2',
              'HC03_EST_VC44',
              'HC03_EST_VC45',
              'HC03_EST_VC46',
              'HC03_EST_VC47')

df = subset(dat, select = variables); rm(variables)
df = df[2:nrow(df),]

df[, c(2:ncol(df))] = sapply(df[, c(2:ncol(df))], as.numeric) # convert to numeric

# summary(lm(HC03_EST_VC44 ~ HC03_EST_VC47, data = df))$r.squared
# summary(lm(HC03_EST_VC45 ~ HC03_EST_VC47, data = df))$r.squared
# summary(lm(HC03_EST_VC46 ~ HC03_EST_VC47, data = df))$r.squared
 
df = melt(df, id.vars = c('GEO.id2', 'HC03_EST_VC47'))

# Rename variables 
df$variable = gsub('HC03_EST_VC44', 
                   'Less than high school graduate', 
                   df$variable)
df$variable = gsub('HC03_EST_VC45', 
                   'High school graduate (includes equivalency)', 
                   df$variable)
df$variable = gsub('HC03_EST_VC46', 
                   "Some college or associate's degree", 
                   df$variable)

colnames(df) = c('id', 'BAorHigher', 'Variable', 'Value')

df$Variable = factor(df$Variable,
                     levels = c('Less than high school graduate',
                                'High school graduate (includes equivalency)',
                                "Some college or associate's degree"))

df = na.omit(df)
write.csv(df, '../scatter.csv', row.names = F)

font = "Source Sans Pro" ## set font for graph
fsize = 5.5 ## set font size for graph
footer = 35 ## font 7 = 43; font 8 = 37.5

png(file = "../dataGraphs/Figure 2. Scatter plots vs. BAorHigher.png", width = 6, height = 3, units = "in", res = 600)
p <- ggplot(df, aes(x=BAorHigher, y=Value, color = Variable)) + 
        geom_point(size = .1) + 
        labs(x = "") +
        labs(y = "Employment-Population Ratio, population 25 to 64 years") + 
        ggtitle("Employment-Population Ratio, population 25 to 64 years, by County (vs. Bachelor's degree or higher)") + 
        scale_x_continuous(limits = c(0,100), breaks = c(0, 20, 40, 60, 80, 100)) +
        scale_y_continuous(limits = c(0,100), breaks = c(0, 20, 40, 60, 80, 100)) + 
        scale_color_manual(values = c('#8c510a', '#d8b365', '#5ab4ac')) + 
        theme_bw() + 
        theme(panel.grid.minor = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.major.y = element_line(color='#E1E1E1', linetype = 'dashed', size = .1),
              strip.background = element_blank(),
              # panel.border = element_blank(),
              panel.border = element_rect(color='#bdbdbd'),
              panel.spacing.y=unit(-.05, "cm"),
              legend.position = "none",
              axis.ticks = element_blank(),
              plot.title = element_text(size = fsize, family = font, face = 'bold', hjust = 0.5),
              strip.text.x = element_text(size = fsize, family = font),
              axis.text.x = element_text(size = fsize, family = font),
              axis.text.y = element_text(size = fsize, family = font),
              axis.title.x = element_text(size = fsize, family = font),
              axis.title.y = element_text(size = fsize, family = font))
p + facet_wrap(~ Variable, ncol=3, scales = "fixed")
grid.text('Source: U.S. Census Bureau, 2011-2015 American Community Survey 5-Year Estimates (S2301, EMPLOYMENT STATUS)',
          vjust=footer, gp = gpar(fontfamily=font, fontsize = fsize-1))
dev.off()


# TOP-BOTTOM: Read in county-level data and US totals ####
dat = read.csv('../dataRaw/ACS_15_5YR_S2301_with_ann.csv', 
               header = T,
               stringsAsFactors = F)

dat = dat[2:nrow(dat),]

# Employment vs. population 
variables = c('GEO.id2',
              'HC03_EST_VC44',
              'HC03_EST_VC45',
              'HC03_EST_VC46',
              'HC03_EST_VC47')

# Subset only emp-pop variables 
df = subset(dat, select = variables); rm(variables)

df[, c(2:ncol(df))] = sapply(df[, c(2:ncol(df))], as.numeric) # convert to numeric

colnames(df) = c('id', 'NoHS', 'HS', 'SomeCollege', 'BAorHigher')

df = na.omit(df)

# Subset bottom quartile for each variable
datf = as.data.frame(df$id); colnames(datf) = 'id'

datBottom = subset(df, NoHS <= quantile(df$NoHS, 0.2))
datBottom = subset(datBottom, select = c('id', 'NoHS'))
datf = merge(datf, datBottom, by.datf = 'id', by.datBottom = 'id', all = T)

datBottom = subset(df, HS <= quantile(df$HS, 0.2))
datBottom = subset(datBottom, select = c('id', 'HS'))
datf = merge(datf, datBottom, by.datf = 'id', by.datBottom = 'id', all = T)

datBottom = subset(df, SomeCollege <= quantile(df$SomeCollege, 0.2))
datBottom = subset(datBottom, select = c('id', 'SomeCollege'))
datf = merge(datf, datBottom, by.datf = 'id', by.datBottom = 'id', all = T)

datBottom = subset(df, BAorHigher <= quantile(df$BAorHigher, 0.2))
datBottom = subset(datBottom, select = c('id', 'BAorHigher'))
datf = merge(datf, datBottom, by.datf = 'id', by.datBottom = 'id', all = T)

rm(datBottom)

datf$na_count <- apply(datf, 1, function(x) sum(is.na(x)))

datf = datf[datf$na_count == 0,]

datf = subset(datf, select = c("id", "NoHS", "HS", 
                               "SomeCollege", "BAorHigher"))

datBottom = datf; rm(datf)

# Subset top quartile for each variable ####
datf = as.data.frame(df$id); colnames(datf) = 'id'

datTop = subset(df, NoHS >= quantile(df$NoHS, 0.8))
datTop = subset(datTop, select = c('id', 'NoHS'))
datf = merge(datf, datTop, by.datf = 'id', by.datTop = 'id', all = T)

datTop = subset(df, HS >= quantile(df$HS, 0.8))
datTop = subset(datTop, select = c('id', 'HS'))
datf = merge(datf, datTop, by.datf = 'id', by.datTop = 'id', all = T)

datTop = subset(df, SomeCollege >= quantile(df$SomeCollege, 0.8))
datTop = subset(datTop, select = c('id', 'SomeCollege'))
datf = merge(datf, datTop, by.datf = 'id', by.datTop = 'id', all = T)

datTop = subset(df, BAorHigher >= quantile(df$BAorHigher, 0.8))
datTop = subset(datTop, select = c('id', 'BAorHigher'))
datf = merge(datf, datTop, by.datf = 'id', by.datTop = 'id', all = T)

rm(datTop)

datf$na_count <- apply(datf, 1, function(x) sum(is.na(x)))

datf = datf[datf$na_count == 0,]

datf = subset(datf, select = c("id", "NoHS", "HS", 
                               "SomeCollege", "BAorHigher"))

datTop = datf; rm(datf)

datBottom$Rank = 'Bottom 20%'
datTop$Rank = 'Top 20%'

df = rbind(datTop, datBottom)
rm(datTop, datBottom)

df$id = droplevels(df$id)

df = subset(df, select = c('id', 'Rank'))

write.csv(df, '../topbottomMap.csv', row.names = F)
