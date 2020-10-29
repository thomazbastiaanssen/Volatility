# Load Libraries ---------------------------------

library(tidyverse)
library(vegan)
library(ggplot2)
library(ggforce)
library(grid)
library(ggrepel)
library(fossil)
library(reshape2)
library(metagenomeSeq)
library(coda.base)
library(zCompositions)
library(ALDEx2)
library(Tjazi)
library(qvalue)
library(iNEXT)
library(omixerRpm)
library(patchwork)

options(stringsAsFactors = F)
getwd()
setwd("/home/thomaz/Documents/PhD/VOLATILITY_validation/Merged_analysis/")

# Taxonomic analysis ---------------------------------


metadata  <- read.delim("metadata_merged.csv", sep = ",")

counts    <- read.delim("Merged_genus_table_from_dada2.csv", sep=",", row.names=1) #mind the encoding UTF-7 vs UTF-8 issues


#View(counts)
counts

counts = counts[-138,]


counts <- counts[,metadata$ID]
dim(counts)
species   <- counts
species   <- apply(species,c(1,2),function(x) as.numeric(as.character(x)))
species   <- species[apply(species == 0, 1, sum) <= (ncol(species) *0.90 ), ]   #remove rows with 2 or fewer hits

set.seed(0)

conds       <- c(rep("A", ncol(species)-10 ), rep("B", 10)) #If you have less than 12 animals, adjust!
species.clr <- aldex.clr(species, conds, mc.samples = 1000, denom="all", verbose=TRUE, useMC=TRUE) 
species.eff <- aldex.effect(species.clr, verbose = TRUE, include.sample.summary = TRUE)
colnames(species.eff) <- gsub(pattern = "rab.sample.", replacement = "", x = colnames(species.eff))

species.exp <- (species.eff[,c(4:(ncol(species.eff)-4))]) #remove the useless t-test-like results


pairsa = which(metadata$Mouse_ID == unique(metadata$Mouse_ID))
pairsb = which(duplicated(metadata$Mouse_ID))
pairsa
pairsb

dis <- c()

for(samp in 1:(nrow(metadata)/2)){
  print(colnames(species.exp)[pairsa[samp]])
  dis[samp] <- dist(t(
    data.frame(unlist(species.exp[,pairsa[samp]]), 
               unlist(species.exp[,pairsb[samp]]))
  ), method = "euclidian")
}

gg_df = metadata[metadata$Timepoint == "Pre",]

gg_df$disait = dis


CORT <- ggplot(data = gg_df[gg_df$Legend != "Control" & gg_df$SIT.Ratio < 3.5,], aes(x = disait, y = PM.CORT_opt2, fill = Legend, group = Legend, label = Mouse_ID)) + 
  geom_smooth(method = "lm", se = F, aes(linetype = Cohort)) +  geom_point(shape = 21, size = 3, stroke = 1) +
  facet_wrap(~Cohort, scales = "free")+ ylab("PM Corticosterone (ng/ml)")+ xlab("Volatility (Aitchison distance)")   + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +theme_bw() + guides(fill = "none", linetype = "none") + scale_linetype_manual(values = c("Discovery" = "solid", 
                                                                                                                                                   "Validation" = "dashed"))

CORT + CAR_POST + plot_layout(widths = c(2, 1))




data.a.pca  <- prcomp(t(species.exp))

pc1 <- round(data.a.pca$sdev[1]^2/sum(data.a.pca$sdev^2),4) *100
pc2 <- round(data.a.pca$sdev[2]^2/sum(data.a.pca$sdev^2),4) *100
pc3 <- round(data.a.pca$sdev[3]^2/sum(data.a.pca$sdev^2),4) *100
pc4 <- round(data.a.pca$sdev[4]^2/sum(data.a.pca$sdev^2),4) *100

pca  = data.frame(PC1 = data.a.pca$x[,1], 
                  PC2 = data.a.pca$x[,2], 
                  PC3 = data.a.pca$x[,3], 
                  PC4 = data.a.pca$x[,4])

pca$ID                   = metadata$Mouse_ID
pca$Legend               = factor(paste(metadata$Timepoint, metadata$Legend), levels = unique(paste(metadata$Timepoint, metadata$Legend))[c(1, 2, 3, 4)])
#pca$Legend               = metadata$Legend
pca$Timepoint            = factor(metadata$Timepoint, levels = c("Pre", "Post"))
pca$Cohort               = metadata$Cohort


fig1a = ggplot(pca[pca$Cohort == "Discovery",], aes(x=PC1, y=PC2, fill = Legend, col = Legend, group = ID, shape = Legend)) + 
  geom_line() + 
  geom_point(size   = 3, 
             col    = "black", 
             stroke = 1) +
  xlab(paste("PC1: ", pc1,  "%", sep= "")) + 
  ylab(paste("PC2: ", pc2,  "%", sep= "")) + 
  theme_bw()  + 
  scale_shape_manual(values  = c("Pre Control"     = 21, 
                                 "Post Control"    = 24, 
                                 "Pre Stress"     = 21, 
                                 "Post Stress"    = 24), labels = c("", "", "Control", "Stress")) +
  scale_fill_manual(values   = c("Pre Control" = "#1f78b4", 
                                 "Pre Stress"  = "#e31a1c", 
                                 "Post Control" = "#1f78b4", 
                                 "Post Stress"  = "#e31a1c"), labels = c("", "", "Control", "Stress")) +
  scale_colour_manual(values = c("Pre Control"  = "#3690c0", 
                                 "Pre Stress"   = "#cb181d",
                                 "Post Control" =  "#3690c0", 
                                 "Post Stress"  = "#cb181d"), labels = c("", "", "Control", "Stress")) + 
  facet_wrap(~Cohort, scales = "free_x", dir = "v", strip.position = "top")+
  guides(fill = guide_legend(ncol = 2, title = "Pre   Post"), 
         col  = guide_legend(ncol = 2, title = "Pre   Post"), 
         shape =guide_legend(ncol = 2, title = "Pre   Post")) +
  theme(legend.position = c(0.88, 0.125), legend.background = element_rect(linetype="solid", 
                                                                           colour ="black")) 



fig1a

fig1c = ggplot(pca[pca$Cohort != "Discovery",], aes(x=PC1, y=PC2, fill = Legend, col = Legend, group = ID, shape = Legend)) + 
  geom_line() + 
  geom_point(size   = 3, 
             col    = "black", 
             stroke = 1) +
  xlab(paste("PC1: ", pc1,  "%", sep= "")) + 
  ylab(paste("PC2: ", pc2,  "%", sep= "")) + 
  theme_bw()  + 
  scale_shape_manual(values  = c("Pre Control"     = 21, 
                                 "Post Control"    = 24, 
                                 "Pre Stress"     = 21, 
                                 "Post Stress"    = 24), labels = c("", "", "Control", "Stress")) +
  scale_fill_manual(values   = c("Pre Control" = "#1f78b4", 
                                 "Pre Stress"  = "#e31a1c", 
                                 "Post Control" = "#1f78b4", 
                                 "Post Stress"  = "#e31a1c"), labels = c("", "", "Control", "Stress")) +
  scale_colour_manual(values = c("Pre Control"  = "#3690c0", 
                                 "Pre Stress"   = "#cb181d",
                                 "Post Control" =  "#3690c0", 
                                 "Post Stress"  = "#cb181d"), labels = c("", "", "Control", "Stress")) + 
  facet_wrap(~Cohort, scales = "free_x", dir = "v", strip.position = "top")+
  guides(fill = guide_legend(ncol = 2, title = "Pre   Post"), 
         col  = guide_legend(ncol = 2, title = "Pre   Post"), 
         shape =guide_legend(ncol = 2, title = "Pre   Post")) +
  theme(legend.position = c(0.88, 0.125), legend.background = element_rect(linetype="solid", 
                                                                           colour ="black")) 



fig1c

fig1a + fig1b + fig1c + fig1d + plot_layout(widths = c(2, 1)) + plot_annotation(tag_levels = "A" )





ggplot(data = gg_df, aes(x = Reactivity, y = disait, fill = Reactivity, group = Reactivity))+ 
  geom_boxplot(alpha = 1/4) +
  geom_dotplot(binaxis='y', 
               stackdir = "center",  
               #  position = position_dodge(width = 0.9), 
               binwidth = 0.1, dotsize = 4
  ) +
  facet_wrap(~Cohort) + guides(fill = "none") + xlab("") + ylab("") + theme_bw()




fig1b  = ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5 & gg_df$Cohort == "Discovery",], aes(x = Legend, y = disait, fill = Legend, group = Legend) ) + 
  geom_boxplot(alpha = 1/4, coef = 1000)+
  stat_boxplot(coef = 1000, geom = "errorbar", width = 1/3 )+
  geom_sina(shape = 21, 
            size  = 3, 
            col   = "black", 
            stroke = 1, maxwidth = 1/5) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  ylab("Volatility (Aitchison's distance)") + 
  xlab("") + 
  ylim(c(17, 37))+
  annotate("text", label = "#", x = 1.5, y = 36, size = 8)+
  facet_wrap(~Cohort, dir = "v") + 
  theme_bw() + guides(fill = "none")

fig1b

fig1d  = ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5 & gg_df$Cohort != "Discovery",], aes(x = Legend, y = disait, fill = Legend, group = Legend) ) + 
  geom_boxplot(alpha = 1/4, coef = 1000)+
  stat_boxplot(coef = 1000, geom = "errorbar", width = 1/3 )+
  geom_sina(shape = 21, 
            size  = 3, 
            col   = "black", 
            stroke = 1, maxwidth = 1/5) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  ylab("Volatility (Aitchison's distance)") + 
  ylim(c(17, 37))+
  annotate("text", label = "*", x = 1.5, y = 36, size = 10)+
  xlab("") + 
  facet_wrap(~Cohort, dir = "v") + 
  theme_bw() + guides(fill = "none")

fig1d


fig1a + fig1b + fig1c + fig1d + plot_layout(widths = c(2, 1))

ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5,], aes(x = disait, y = SIT.Ratio, fill = Legend, group = Legend) ) + 
  geom_point(shape = 21, 
             size  = 3, 
             col   = "black", stroke = 1.1) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  ylim(c(0,3)) + 
  geom_smooth(method = "lm", se = F, aes(col = Legend, linetype = Legend)) + 
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted"))+
  ylab("Social Interaction Test Ratio") + 
  xlab("Volatility (Aitchison's distance)") + 
  facet_wrap(~Cohort, scales = "free_x") + 
  theme_bw()  + theme(legend.position = "none")




pchaod <- ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5  & gg_df$Cohort == "Discovery",], aes(x = disait, y = chao1, fill = Legend, group = Legend) ) + 
  geom_point(shape = 21, 
             size  = 2, 
             col   = "black", stroke = 1) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F, aes(col = Legend, linetype = Legend)) + 
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted"))+
  ylab("Difference in Chao1") + 
  xlab("Volatility (Aitchison distance)") + 
  facet_wrap(~Cohort, dir = "v") + 
  theme_bw()  + theme(legend.position = "none")


pchaod

psimpsd <- ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5  & gg_df$Cohort == "Discovery",], aes(x = disait, y = simp, fill = Legend, group = Legend) ) + 
  geom_point(shape = 21, 
             size  = 2, 
             col   = "black", stroke = 1) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F, aes(col = Legend, linetype = Legend)) + 
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted"))+ 
  ylab("Difference in Simpson Index") + 
  xlab("Volatility (Aitchison distance)") + 
  facet_wrap(~Cohort, dir = "v") + 
  theme_bw()  + theme(legend.position = "none")


psimpsd

pshand <- ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5  & gg_df$Cohort == "Discovery",], aes(x = disait, y = shan, fill = Legend, group = Legend) ) + 
  geom_point(shape = 21, 
             size  = 2, 
             col   = "black", stroke = 1) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F, aes(col = Legend, linetype = Legend)) + 
  scale_linetype_manual(values= c("Stress" = "dashed", 
                                  "Control" = "dotted"))+ 
  ylab("Difference in Shannon Index") + 
  xlab("Volatility (Aitchison distance)") + 
  facet_wrap(~Cohort, dir = "v") + 
  theme_bw()  + theme(legend.position = "none")

pshand


pchaov <- ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5 & gg_df$Cohort != "Discovery",], aes(x = disait, y = chao1, fill = Legend, group = Legend) ) + 
  geom_point(shape = 21, 
             size  = 2, 
             col   = "black", stroke = 1) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F, aes(col = Legend, linetype = Legend)) + 
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted"))+ 
  ylab("Difference in Chao1") + 
  xlab("Volatility (Aitchison distance)") + 
  facet_wrap(~Cohort, dir = "v") + 
  theme_bw()  + theme(legend.position = "none")


pchaov

psimpsv <- ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5  & gg_df$Cohort != "Discovery",], aes(x = disait, y = simp, fill = Legend, group = Legend) ) + 
  geom_point(shape = 21, 
             size  = 2, 
             col   = "black", stroke = 1) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F, aes(col = Legend, linetype = Legend)) + 
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted"))+ 
  ylab("Difference in Simpson Index") + 
  xlab("Volatility (Aitchison distance)") + 
  facet_wrap(~Cohort, dir = "v") + 
  theme_bw()  + theme(legend.position = "none")


psimpsv

pshanv <- ggplot(data = gg_df[ gg_df$SIT.Ratio < 3.5  & gg_df$Cohort != "Discovery",], aes(x = disait, y = shan, fill = Legend, group = Legend) ) + 
  geom_point(shape = 21, 
             size  = 2, 
             col   = "black", stroke = 1) + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F, aes(col = Legend, linetype = Legend)) + 
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted"))+ 
  ylab("Difference in Shannon Index") + 
  xlab("Volatility (Aitchison distance)") + 
  facet_wrap(~Cohort, dir = "v")  +
  theme_bw() + theme(legend.position = "none")

pshanv

pchaod + psimpsd + pshand + pchaov + psimpsv + pshanv + 
  plot_layout(guides = "collect") + 
  plot_annotation(tag_levels = "A") 


getwd()

alphadiv <- get_asymptotic_alpha(counts)
alphadiv$Legend = metadata$Legend
gg_df$chao1 = abs(alphadiv$chao1[1:60] - alphadiv$chao1[61:120])
gg_df$simp = abs(alphadiv$asymptotic_simps[1:60] - alphadiv$asymptotic_simps[61:120])
gg_df$shan = abs(alphadiv$asymptotic_shannon[1:60] - alphadiv$asymptotic_shannon[61:120])




ggplot(data = gg_df, aes(x = Reactivity, y = shan, fill = Reactivity, group = Reactivity))+ 
  geom_boxplot(alpha = 1/4) +
  geom_dotplot(binaxis='y', 
               stackdir = "center",  
               #  position = position_dodge(width = 0.9), 
               binwidth = 0.01, dotsize = 1
  ) +
  facet_wrap(~Cohort) + guides(fill = "none") + xlab("") + ylab("") + theme_bw()



#  Differential abundance analysis ---------------------------------


res_df <- pairwise_DA_wrapper(reads       = species, 
                              groups      = paste(metadata$Timepoint, metadata$Cohort, metadata$Reactivity), 
                              comparisons = data.frame(a = c("Pre Discovery Nonreactive", "Pre Validation Nonreactive"), 
                                                       b = c("Pre Discovery Reactive"   , "Pre Validation Reactive")), ignore.posthoc = T
)


# Functional analysis ---------------------------------

listDB()
db   <- loadDB(name ="GBMs.v1.0")
KOs  <- read.delim("ko_abund_table_unnorm.txt", header = T)




#View(head(KOs))
GBMs <- rpm(x = (KOs),  module.db = db, annotation = 1)
colnames(GBMs@abundance)
GBM <- GBMs@abundance

row.names(GBM)  = GBMs@db@module.names[GBMs@annotation$Module,1]
#GBM  = floor(GBM[,metadata[metadata$Timepoint == "Pre",]$ID])
GBM  = floor(GBM[,metadata$ID])

conds       <- c(rep("A", ncol(GBM)-10 ), rep("B", 10)) #If you have less than 12 animals, adjust!

GBM.clr <- aldex.clr(GBM, conds, mc.samples = 1000, denom="all", verbose=TRUE, useMC=TRUE) 
GBM.eff <- aldex.effect(GBM.clr, verbose = TRUE, include.sample.summary = TRUE)
colnames(GBM.eff) <- gsub(pattern = "rab.sample.", replacement = "", x = colnames(GBM.eff))


GBM.exp     <- (GBM.eff[,colnames(GBM)]) #remove the useless t-test-like results

GBM.exp

listDB()
db   <- loadDB(name ="GMMs.v1.07")
KOs  <- read.delim("ko_abund_table_unnorm.txt", header = T)




#View(head(KOs))
GMMs <- rpm(x = (KOs),  module.db = db, annotation = 1)
colnames(GMMs@abundance)
GMM <- GMMs@abundance

row.names(GMM)  = GMMs@db@module.names[GMMs@annotation$Module,1]
#GBM  = floor(GBM[,metadata[metadata$Timepoint == "Pre",]$ID])
GMM  = floor(GMM[,metadata$ID])

conds       <- c(rep("A", ncol(GBM)-10 ), rep("B", 10)) #If you have less than 12 animals, adjust!

GMM.clr <- aldex.clr(GMM, conds, mc.samples = 1000, denom="all", verbose=TRUE, useMC=TRUE) 
GMM.eff <- aldex.effect(GMM.clr, verbose = TRUE, include.sample.summary = TRUE)
colnames(GMM.eff) <- gsub(pattern = "rab.sample.", replacement = "", x = colnames(GMM.eff))


GMM.exp     <- (GMM.eff[,colnames(GMM)]) #remove the useless t-test-like results

GMM.exp




data.a.pca  <- prcomp(t(GBM.exp))

pc1 <- round(data.a.pca$sdev[1]^2/sum(data.a.pca$sdev^2),4) *100
pc2 <- round(data.a.pca$sdev[2]^2/sum(data.a.pca$sdev^2),4) *100
pc3 <- round(data.a.pca$sdev[3]^2/sum(data.a.pca$sdev^2),4) *100
pc4 <- round(data.a.pca$sdev[4]^2/sum(data.a.pca$sdev^2),4) *100

pca  = data.frame(PC1 = data.a.pca$x[,1], 
                  PC2 = data.a.pca$x[,2], 
                  PC3 = data.a.pca$x[,3], 
                  PC4 = data.a.pca$x[,4])

pca$ID                   = metadata$Mouse_ID
pca$Legend               = factor(paste(metadata$Timepoint, metadata$Legend), levels = unique(paste(metadata$Timepoint, metadata$Legend))[c(1, 2, 3, 4)])
#pca$Legend               = metadata$Legend
pca$Timepoint            = factor(metadata$Timepoint, levels = c("Pre", "Post"))
pca$Cohort               = metadata$Cohort


ggplot(pca, aes(x=PC1, y=PC2, fill = Legend, col = Legend, group = ID, shape = Legend)) + 
  geom_line() + 
  geom_point(size   = 3, 
             col    = "black", 
             stroke = 1) +
  xlab(paste("PC1: ", pc1,  "%", sep= "")) + 
  ylab(paste("PC2: ", pc2,  "%", sep= "")) + 
  theme_bw()  + 
  scale_shape_manual(values  = c("Pre Control"     = 21, 
                                 "Post Control"    = 24, 
                                 "Pre Stress"     = 21, 
                                 "Post Stress"    = 24), labels = c("", "", "Control", "Stress")) +
  scale_fill_manual(values   = c("Pre Control" = "#1f78b4", 
                                 "Pre Stress"  = "#e31a1c", 
                                 "Post Control" = "#1f78b4", 
                                 "Post Stress"  = "#e31a1c"), labels = c("", "", "Control", "Stress")) +
  scale_colour_manual(values = c("Pre Control"  = "#3690c0", 
                                 "Pre Stress"   = "#cb181d",
                                 "Post Control" =  "#3690c0", 
                                 "Post Stress"  = "#cb181d"), labels = c("", "", "Control", "Stress")) + 
  facet_wrap(~Cohort, scales = "free_x", dir = "v", strip.position = "top")+
  guides(fill = guide_legend(ncol = 2, title = "Pre   Post"), 
         col  = guide_legend(ncol = 2, title = "Pre   Post"), 
         shape =guide_legend(ncol = 2, title = "Pre   Post")) +
  theme(legend.position = c(0.88, 0.625), legend.background = element_rect(linetype="solid", 
                                                                           colour ="black")) 


res_df_GMM = pairwise_DA_wrapper(reads       = floor(GMM),
                                 groups      = paste(metadata$Timepoint, metadata$Cohort, metadata$Legend), 
                                 comparisons = data.frame(a = c("Pre Discovery Stress"  , "Pre Validation Stress" , "Pre Discovery Control"  , "Pre Validation Control"), 
                                                          b = c("Post Discovery Stress" , "Post Validation Stress", "Post Discovery Control" , "Post Validation Control")), paired.test = T , ignore.posthoc = F)


res_df_GBM = pairwise_DA_wrapper(reads       = floor(GBM),
                                 groups      = paste(metadata$Timepoint, metadata$Cohort, metadata$Legend), 
                                 comparisons = data.frame(a = c("Pre Discovery Stress"  , "Pre Validation Stress" , "Pre Discovery Control"  , "Pre Validation Control"), 
                                                          b = c("Post Discovery Stress" , "Post Validation Stress", "Post Discovery Control" , "Post Validation Control")), paired.test = T , ignore.posthoc = F)


res_df_genera = pairwise_DA_wrapper(reads    = species,
                                    groups      = paste(metadata$Timepoint, metadata$Cohort, metadata$Legend), 
                                    comparisons = data.frame(a = c("Pre Discovery Stress"  , "Pre Validation Stress" , "Pre Discovery Control"  , "Pre Validation Control"), 
                                                             b = c("Post Discovery Stress" , "Post Validation Stress", "Post Discovery Control" , "Post Validation Control")), paired.test = T , ignore.posthoc = F)

GBM_s <- ggplot(data = res_df_GBM, aes(x = `Pre Discovery Stress vs Post Discovery Stress`, 
                                       y = `Pre Validation Stress vs Post Validation Stress` ))+ 
  geom_smooth(method = "lm" , se = F ) +
  geom_point(size = 3, shape = 21, fill = "#e31a1c") + theme_bw()  +
  ylab("Validation Effect Size") + xlab("Discovery Effect Size") + ggtitle("GBM Stress") + guides(col = "none")


GMM_s <- ggplot(data = res_df_GMM, aes(x = `Pre Discovery Stress vs Post Discovery Stress`, 
                                       y   = `Pre Validation Stress vs Post Validation Stress` )) + 
  geom_smooth(method = "lm" , se = F ) +
  geom_point(size = 3, shape = 21, fill = "#e31a1c") + theme_bw()  +
  ylab("Validation Effect Size") + xlab("Discovery Effect Size") + ggtitle("GMM Stress")

GBM_c <- ggplot(data = res_df_GBM, aes(x = `Pre Discovery Control vs Post Discovery Control`, 
                                       y = `Pre Validation Control vs Post Validation Control`)) + 
  geom_smooth(method = "lm" , se = F, linetype = "dotted" ) +
  geom_point(size = 3, shape = 21, fill = "#1f78b4") + theme_bw()  +
  ylab("Validation Effect Size") + xlab("Discovery Effect Size")+ ggtitle("GBM Control")

GMM_c <- ggplot(data = res_df_GMM, aes(x = `Pre Discovery Control vs Post Discovery Control`, 
                                       y = `Pre Validation Control vs Post Validation Control`)) + 
  geom_smooth(method = "lm" , se = F, linetype = "dashed" ) +
  geom_point(size = 3, shape = 21, fill = "#1f78b4") + theme_bw()  +
  ylab("Validation Effect Size") + xlab("Discovery Effect Size")+ ggtitle("GMM Control")

genus_s <- ggplot(data = res_df_genera, aes(x = `Pre Discovery Stress vs Post Discovery Stress`, 
                                            y = `Pre Validation Stress vs Post Validation Stress`)) + 
  geom_smooth(method = "lm" , se = F, linetype = "dotted" ) +
  geom_point(size = 3, shape = 21, fill = "#e31a1c") + theme_bw()  +
  ylab("Validation Effect Size") + xlab("Discovery Effect Size") + ggtitle("Genera Stress")

genus_c <- ggplot(data = res_df_genera, aes(x = `Pre Discovery Control vs Post Discovery Control`, 
                                            y = `Pre Validation Control vs Post Validation Control`)) + 
  geom_smooth(method = "lm" , se = F, linetype = "dotted" ) +
  geom_point(size = 3, shape = 21, fill = "#1f78b4") + theme_bw()  +
  ylab("Validation Effect Size") + xlab("Discovery Effect Size")+ ggtitle("Genera Control")


genus_c + genus_s + GBM_c + GBM_s + GMM_c + GMM_s + plot_layout(ncol = 2) + plot_annotation(tag_levels = "A")

genus_c + GBM_c + GMM_c + genus_s + GBM_s + GMM_s + plot_layout(ncol = 3) + plot_annotation(tag_levels = "A")



# Make volcanoplot for discovery ---------------------------------


vol = read.delim("data_for_volcanoplot.csv", sep = ",")
vol = vol[-20,c("X", "SIT.Ratio", "PM.CORT..Day.11.", "Colon.Length", "GR.Amygdala", "MR.Amygdala", "Legend", "disait")]
vol
gg = vol %>% pivot_longer(!c(Legend, X, disait), names_to = c("Measurement"), values_to = "value")

gg

gg[gg$X == "SR19" & gg$Measurement == "Colon.Length",]$Legend = "Outlier"

ind = ggplot(gg, aes(x = disait, y = value, fill = Legend, colour = Legend,  linetype = Legend, alpha = Legend)) +
  geom_point(shape = 21, 
             size  = 3, 
             col   = "black", stroke = 1.1) + 
  facet_wrap(~Measurement, scales = "free_y", ncol = 2) + theme_bw() + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c", 
                               "Outlier" = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F) +
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted", 
                                  "Outlier" = "dotted")) + 
  scale_alpha_manual(values= c("Stress" = 1, 
                               "Control" = 0.5, 
                               "Outlier" = 0.5))

ed = read.delim("measurements_used_as_input_for_correlation_analysis_of_discovery.csv", sep = ",", row.names = 1)


dis =  ed$disait[-c(1:9,11+9)]
ed = subset(ed, select=-c(Adrenals..R.,  Adrenals..L., AvgAd, disait))

skres <- skadi_kryss(x_vector = data.frame(t(ed))[-45,-c(1:9,11+9)], y_metric = dis, method = "spearman", uncorrected = T, posthoc = F, euclid.outlier.check = T)
skres[skres$p.value < 0.1,]



dis =  ed$disait[-c(1:9)]
ed = subset(ed, select=-c(Adrenals..R.,  Adrenals..L., AvgAd, disait))
skres <- skadi_kryss(x_vector = data.frame(t(ed))[-45,-c(1:9)], y_metric = dis, method = "spearman", uncorrected = T, posthoc = F, euclid.outlier.check = T)





nicenames <- gsub("\\.\\.",replacement = ".", row.names(skres))
nicenames <- gsub("\\.",replacement = " ", nicenames)

nicenames[34:35] = c("Nr3c1 Amygdala", 
                     "Nr3c2 Amygdala")



gg_volc =  data.frame(microbes = nicenames, 
                      pvals = skres$p.value, 
                      evals = skres$statistic)

v1 = ggplot(gg[gg$Measurement == "SIT.Ratio",], aes(x = disait, y = value, fill = Legend, colour = Legend,  linetype = Legend, alpha = Legend)) +
  geom_point(shape = 21, 
             size  = 3, 
             col   = "black", stroke = 1.1) +  theme_bw() + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c", 
                               "Outlier" = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F) +
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted", 
                                  "Outlier" = "dotted")) + 
  scale_alpha_manual(values= c("Stress" = 1, 
                               "Control" = 0.5, 
                               "Outlier" = 0.5)) + 
  xlab("") + ylab("SIT Ratio") + ggtitle("Social Interaction") + guides(fill     = "none", 
                                                                        linetype = "none", 
                                                                        alpha    = "none", 
                                                                        colour   = "none") + theme(title = element_text(size = 10))
v1


v2 = ggplot(gg[gg$Measurement == "PM.CORT..Day.11.",], aes(x = disait, y = value, fill = Legend, colour = Legend,  linetype = Legend, alpha = Legend)) +
  geom_point(shape = 21, 
             size  = 3, 
             col   = "black", stroke = 1.1) +  theme_bw() + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c", 
                               "Outlier" = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F) +
  scale_linetype_manual(values= c("Stress" = "dashed", 
                                  "Control" = "dotted", 
                                  "Outlier" = "dotted")) + 
  scale_alpha_manual(values= c("Stress" = 1, 
                               "Control" = 0.5, 
                               "Outlier" = 0.5)) + 
  xlab("") + ylab("CORT (ng/ml)") + ggtitle("Corticosterone Levels") + guides(fill     = "none", 
                                                                              linetype = "none", 
                                                                              alpha    = "none", 
                                                                              colour   = "none") + theme(title = element_text(size = 10))
v2

v3 = ggplot(gg[gg$Measurement == "GR.Amygdala",], aes(x = disait, y = value, fill = Legend, colour = Legend,  linetype = Legend, alpha = Legend)) +
  geom_point(shape = 21, 
             size  = 3, 
             col   = "black", stroke = 1.1) +  theme_bw() + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c", 
                               "Outlier" = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F) +
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted", 
                                  "Outlier" = "dotted")) + 
  scale_alpha_manual(values= c("Stress" = 1, 
                               "Control" = 0.5, 
                               "Outlier" = 0.5)) + 
  xlab("")  + ylab(expression("Fold Change (" *Delta*Delta*"Ct)")) + ggtitle(expression(paste(italic("Nr3c1"),  " Expression in Amygdala")))  + guides(fill     = "none", 
                                                                                                                                                       linetype = "none", 
                                                                                                                                                       alpha    = "none", 
                                                                                                                                                       colour   = "none") + theme(title = element_text(size = 10))
v3

v4 = ggplot(gg[gg$Measurement == "MR.Amygdala",], aes(x = disait, y = value, fill = Legend, colour = Legend,  linetype = Legend, alpha = Legend)) +
  geom_point(shape = 21, 
             size  = 3, 
             col   = "black", stroke = 1.1) +  theme_bw() + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c", 
                               "Outlier" = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F) +
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted", 
                                  "Outlier" = "dotted")) + 
  scale_alpha_manual(values= c("Stress" = 1, 
                               "Control" = 0.5, 
                               "Outlier" = 0.5)) + 
  xlab("") + ylab(expression("Fold Change (" *Delta*Delta*"Ct)")) + ggtitle(expression(paste(italic("Nr3c2"),  " Expression in Amygdala")))  + 
  theme(title = element_text(size = 10), legend.box.background = element_rect(colour = "black"))
v4


v5 = ggplot(gg[gg$Measurement == "Colon.Length",], aes(x = disait, y = value, fill = Legend, colour = Legend,  linetype = Legend, alpha = Legend)) +
  geom_point(shape = 21, 
             size  = 3, 
             col   = "black", stroke = 1.1) +  theme_bw() + 
  scale_fill_manual(values = c("Control" = "#1f78b4", 
                               "Stress"  = "#e31a1c", 
                               "Outlier" = "#e31a1c")) +
  scale_colour_manual(values = c("Control" = "#3690c0", 
                                 "Stress"  = "#cb181d")) +
  geom_smooth(method = "lm", se = F) +
  scale_linetype_manual(values= c("Stress" = "solid", 
                                  "Control" = "dotted", 
                                  "Outlier" = "dotted")) + 
  scale_alpha_manual(values= c("Stress" = 1, 
                               "Control" = 0.5, 
                               "Outlier" = 0.5)) + 
  xlab("") + ylab("(cm)") + ggtitle("Colon Length") + guides(fill     = "none", 
                                                             linetype = "none", 
                                                             alpha    = "none", 
                                                             colour   = "none") + theme(title = element_text(size = 10))
v5



v =   ggplot(data = gg_volc, aes(x = evals, 
                                 y = pvals, 
                                 label = microbes))  + 
  geom_point(shape = 21, size = 3, stroke = 1, fill = "#e31a1c") + 
  scale_y_continuous(breaks = c(0.001, 0.01, 0.05, 0.2, 1), 
                     trans = "log10") + 
  geom_hline(col = "red", linetype = "dashed", yintercept = 0.05) + 
  theme_bw() + ylab("p-value (log10 scale)") + xlab("Spearman's Rho") + 
  geom_text_repel(data = subset(gg_volc, 
                                pvals < 0.05),  
                  aes(x     = evals, 
                      y     = pvals, 
                      label = microbes), box.padding = 1)

zooms = v1 + v2 + v3 + v4 + v5 + guide_area() + plot_layout(ncol = 2, guides = 'collect') & theme(legend.background = element_rect(colour = "black"), 
                                                                                                  legend.text = element_text(size = 12), 
                                                                                                  legend.title = element_text(size = 12), 
                                                                                                  legend.key.size = unit(1, "cm"))

v + zooms + plot_annotation(tag_levels = "A")
