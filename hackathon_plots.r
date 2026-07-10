library(tidyverse)
library(ggplot2)
library(scales)
library(gridExtra)

df <- read.csv("deidentified_interest_form_responses.csv", stringsAsFactors = FALSE)
colnames(df) <- c("Timestamp", "StudyLevel", "Program", "PriorProgramming",
                  "PythonComfort", "PythonEnv", "OtherLanguages",
                  "NeuroCourse", "InterestTopics", "CareerHelp",
                  "SuggestedTopics", "ComputerAccess", "CV")

# ── Branding palette ──────────────────────────────────────────────────────────
pal <- c("#1B4332", "#2D6A4F", "#40916C", "#74C69D", "#B7E4C7")

# Shared academic theme
theme_academic <- function() {
  theme_classic(base_size = 12, base_family = "sans") +
    theme(
      plot.title    = element_text(face = "bold", size = 13, hjust = 0),
      plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0),
      plot.caption  = element_text(size = 8, color = "gray50", hjust = 1),
      axis.text     = element_text(size = 10, color = "gray20"),
      axis.title    = element_text(size = 10, color = "gray20"),
      panel.grid.major.x = element_line(color = "gray90", linewidth = 0.4),
      panel.grid.major.y = element_blank(),
      plot.margin   = margin(10, 20, 10, 10)
    )
}

# ── Summary tables ────────────────────────────────────────────────────────────
study_summary  <- df %>% count(StudyLevel) %>% arrange(desc(n)) %>%
                    mutate(pct = round(n / sum(n) * 100, 1))
python_comfort <- df %>% count(PythonComfort) %>% arrange(PythonComfort)
programming_exp <- table(df$PriorProgramming)
neuro_background <- table(df$NeuroCourse)

all_languages <- df$OtherLanguages %>%
  strsplit(",") %>% unlist() %>% trimws() %>%
  .[!. %in% c("", "No", "No other programming languages",
              "None", "None of the above", "Nothing", "non", "NON")]

language_freq <- table(all_languages) %>% sort(decreasing = TRUE)

# ── P1: Study Level ───────────────────────────────────────────────────────────
p1 <- ggplot(study_summary, aes(x = reorder(StudyLevel, n), y = n)) +
  geom_col(fill = pal[2], width = 0.65) +
  geom_text(aes(label = paste0(n, " (", pct, "%)")),
            hjust = -0.1, size = 3.2, color = "gray20") +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Applicants by Study Level",
       x = NULL, y = "Number of Applicants",
       caption = paste0("N = ", nrow(df))) +
  theme_academic()

# ── P2: Python Comfort ────────────────────────────────────────────────────────
comfort_labels <- c("1" = "1\nNo experience", "2" = "2\nBasic",
                    "3" = "3\nIntermediate",  "4" = "4\nAdvanced",
                    "5" = "5\nExpert")

p2 <- ggplot(python_comfort, aes(x = factor(PythonComfort), y = n,
                                  fill = factor(PythonComfort))) +
  geom_col(width = 0.65) +
  geom_text(aes(label = n), vjust = -0.5, size = 3.5, color = "gray20") +
  scale_fill_manual(values = pal, guide = "none") +
  scale_x_discrete(labels = comfort_labels) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Python Comfort Level",
       subtitle = "Self-reported; 1 = No experience, 5 = Very comfortable",
       x = NULL, y = "Number of Applicants",
       caption = paste0("N = ", nrow(df))) +
  theme_academic() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "gray90", linewidth = 0.4))

# ── P3: Prior Programming (bar instead of pie — cleaner for papers) ────────────
prog_df <- data.frame(Response = names(programming_exp),
                      Count = as.numeric(programming_exp)) %>%
  mutate(pct = round(Count / sum(Count) * 100, 1),
         Response = factor(Response, levels = c("Yes", "No")))

p3 <- ggplot(prog_df, aes(x = Response, y = Count, fill = Response)) +
  geom_col(width = 0.5) +
  geom_text(aes(label = paste0(Count, "\n(", pct, "%)")),
            vjust = -0.4, size = 3.5, color = "gray20") +
  scale_fill_manual(values = c("Yes" = pal[2], "No" = pal[4]), guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Prior Programming Experience",
       x = NULL, y = "Number of Applicants",
       caption = paste0("N = ", nrow(df))) +
  theme_academic() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "gray90", linewidth = 0.4))

# ── P4: Neuroscience Background ───────────────────────────────────────────────
neuro_df <- data.frame(Response = names(neuro_background),
                       Count = as.numeric(neuro_background)) %>%
  mutate(pct = round(Count / sum(Count) * 100, 1),
         Response = factor(Response, levels = c("Yes", "No")))

p4 <- ggplot(neuro_df, aes(x = Response, y = Count, fill = Response)) +
  geom_col(width = 0.5) +
  geom_text(aes(label = paste0(Count, "\n(", pct, "%)")),
            vjust = -0.4, size = 3.5, color = "gray20") +
  scale_fill_manual(values = c("Yes" = pal[1], "No" = pal[3]), guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Prior Neuroscience/Biomedical Imaging Course",
       x = NULL, y = "Number of Applicants",
       caption = paste0("N = ", nrow(df))) +
  theme_academic() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "gray90", linewidth = 0.4))

# ── P5: Other Languages (cleaned) ────────────────────────────────────────────
lang_df <- data.frame(Language = names(language_freq),
                      Count = as.numeric(language_freq)) %>%
  arrange(desc(Count)) %>% head(8)

p5 <- ggplot(lang_df, aes(x = reorder(Language, Count), y = Count)) +
  geom_col(fill = pal[3], width = 0.65) +
  geom_text(aes(label = Count), hjust = -0.2, size = 3.2, color = "gray20") +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Other Programming Languages Known",
       subtitle = "Top 8; excludes non-language responses",
       x = NULL, y = "Number of Applicants") +
  theme_academic()

# ── P6: Top Programs ──────────────────────────────────────────────────────────
program_counts <- df %>% count(Program) %>% arrange(desc(n)) %>% head(10)

p6 <- ggplot(program_counts, aes(x = reorder(Program, n), y = n)) +
  geom_col(fill = pal[2], width = 0.65) +
  geom_text(aes(label = n), hjust = -0.2, size = 3.2, color = "gray20") +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Top 10 Program Concentrations",
       x = NULL, y = "Number of Applicants") +
  theme_academic()

# ── Print & Save ──────────────────────────────────────────────────────────────
walk(list(p1, p2, p3, p4, p5, p6), print)

ggsave("study_level.png",      p1, width = 8,  height = 5, dpi = 300)
ggsave("python_comfort.png",   p2, width = 7,  height = 5, dpi = 300)
ggsave("programming_exp.png",  p3, width = 5,  height = 5, dpi = 300)
ggsave("neuro_background.png", p4, width = 5,  height = 5, dpi = 300)
ggsave("other_languages.png",  p5, width = 8,  height = 5, dpi = 300)
ggsave("programs.png",         p6, width = 10, height = 6, dpi = 300)
