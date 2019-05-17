# DEMO ONLY
# TODO: Replace with NLP

class Parser
  def self.parse(sd_meta_datum)
    report_title = "Nonsurgical Treatments for Urinary Incontinence in Women: A Systematic Review Update"
    date_of_last_search = Date.parse('4-12-2017')
    date_of_publication_to_srdr = Date.parse('1-9-2018')
    date_of_publication_full_report = Date.parse('1-8-2018')
    stakeholder_involvement_extent =
    "We would also like to thank and acknowledge the following people who provided insights related to the Contextual Question: Heidi Brown, M.D. (University of Wisconsin School of Medicine and Public Health), Mary McLennan, M.D. (Saint Louis University), Vivian Sung, M.D. (Brown University), Donna Thompson, M.S.N. (Society of Urologic Nurses and Associates), and Blair Washington, M.D. (Virginia Mason Medical Center)." +
    " Based on feedback from a stakeholder panel, this update focuses on the comparative benefits and harms of nonsurgical treatments, both nonpharmacological and pharmacological." +
    " Based on input from clinicians and nurses who treate women with UI, patient advocates, and articles found from our primary and grey literature searches, cure (or complete resolution) of UI symptoms (incontinence, urgency, and frequency), rather than cure of UI itself, is highest priority for most women with UI." +
    " The Patient-Centered Research Outcomes Institute (PCORI) held a multi-stakeholder virtual workshop on December 7, 2016, to discuss potential scoping for the updated review, including the prioritization of key questions (KQ), a discussion of where the evidence base has accumulated since the prior review, and emerging issues of importance to the field. Stakeholders included patients, clinicians and allied health professionals, professional organizations, research funders, payers, and industry. The full participant list, presentation slides from the meeting, and an audio recording of the entire discussion can be found at the PCORI Web site (http://www.pcori.org/events/2016/updating-systematic-reviews-pcori-virtual-multi-stakeholder- workshop-nonsurgical).    Stakeholders agreed that the questions regarding treatment of UI still represented critical issues. Several specific interventions were brought up during the meeting as important for the review to address. These included (1) mirabegron, (2) Impressa®, a vaginal insert manufactured by Poise®, (3) onabotulinum toxin A (BTX) injections, (4) nerve stimulation interventions, and (5) “lifestyle” interventions (e.g., bladder irritant reductions, fluid management).    Stakeholders were particularly interested in treatment effectiveness in specific patient populations. These included (1) women athletes and those engaging in high-impact physical activity, (2) older women, (3) military women or veterans, and (4) racial and ethnic minorities.    Based on stakeholder input, the 2012 AHRQ review Key Question (KQ) 1 on the diagnostic evaluation of UI was deemed to be of lower priority for updating at this time. Stakeholders also noted that it is important to summarize information on how patients define successful treatment." +
    " Stakeholders, including Key Informants and Technical Experts, participated in a virtual workshop by the Patient-Centered Research Outcomes Institute (PCORI) in December 2016 to help formulate the research protocol. Details on the virtual workshop, including a list of participants, can be found at https://www.pcori.org/events/2016/updating-systematic-reviews- pcori-virtual-multi-stakeholder-workshop-nonsurgical.    Key Informants in the workshop included end users of research, such as patients and caregivers, practicing clinicians, relevant professional and consumer organizations, purchasers of health care, and others with experience in making health care decisions. Technical Experts in the workshop included multidisciplinary groups of clinical, content, and methodological experts who provided input in defining populations, interventions, comparisons, and outcomes and identified particular studies or databases to search. They were selected to provide broad expertise and perspectives specific to the topic under development.    During the virtual workshop, stakeholders reviewed scoping for the updated review, prioritized key questions, and discussed where the evidence base has accumulated since the prior review and emerging issues in urinary incontinence. A protocol on nonpharmacological and pharmacological treatments of urinary incontinence was developed based upon findings from the workshop.    Key Informants and Technical Experts do not do analysis of any kind nor do they contribute to the writing of the report. They have not reviewed the report, except as given the opportunity to do so through the peer or public review mechanisms."
    authors_conflict_of_interest_of_full_report = ''
    stakeholders_conflict_of_interest = ''
    prototcol_link = ''
    full_report_link = 'https://www.ncbi.nlm.nih.gov/books/NBK534614/'
    structured_abstract_link = 'https://www.ncbi.nlm.nih.gov/books/NBK534625/'
    key_messages_link = ''
    abstract_summary_link = ''
    evidence_summary_link = "https://www.ncbi.nlm.nih.gov/books/NBK534627/#ch1.s1"
    evs_introduction_link = "https://www.ncbi.nlm.nih.gov/books/NBK534627/#ch1.s1"
    evs_methods_link = "https://www.ncbi.nlm.nih.gov/books/NBK534627/#_ch1_s2_"
    evs_results_link = "https://www.ncbi.nlm.nih.gov/books/NBK534627/#ch1.s4"
    evs_discussion_link = "https://www.ncbi.nlm.nih.gov/books/NBK534627/#_ch1_s5_"
    evs_conclusions_link = "https://www.ncbi.nlm.nih.gov/books/NBK534627/#ch1.s5.6"
    evs_tables_figures_link = "https://www.ncbi.nlm.nih.gov/books/NBK534627/table/ch1.tab12/?report=objectonly"
    disposition_of_comments_link = ''
    srdr_data_link = ''
    most_previous_version_srdr_link = ''
    most_previous_version_full_report_link = ''
    overall_purpose_of_review = "To update the evidence on the topic of nonsurgical treatments for UI in women. (See AHRQ Pub No. 11(12)-EHC074-EF, April 2012).\nTo conduct a systematic review and meta-analyses of the comparative effectiveness and harms of nonpharmacological and pharmacological interventions for women with all forms of UI.\nTo summarize information on how women with UI define a successful outcome, and to highlight data on these outcomes."
    type_of_review = ''
    level_of_analysis = ''
    authors = [
      "Ethan Balk, M.D., M.P.H.",
      "Gaelen P. Adam, M.L.I.S.",
      "Hannah Kimmel, M.P.H.",
      "Valerie Rofeberg, Sc.M.",
      "Iman Saeed, Sc.M.",
      "Peter Jeppson, M.D.",
      "Thomas Trikalinos, M.D.",
    ].join("\n")

    sd_meta_datum.update(
      authors: authors,
      report_title: report_title,
      date_of_last_search: date_of_last_search,
      date_of_publication_to_srdr: date_of_publication_to_srdr,
      date_of_publication_full_report: date_of_publication_full_report,
      stakeholder_involvement_extent: stakeholder_involvement_extent,
      authors_conflict_of_interest_of_full_report: authors_conflict_of_interest_of_full_report,
      stakeholders_conflict_of_interest: stakeholders_conflict_of_interest,
      prototcol_link: prototcol_link,
      full_report_link: full_report_link,
      structured_abstract_link: structured_abstract_link,
      key_messages_link: key_messages_link,
      abstract_summary_link: abstract_summary_link,
      evidence_summary_link: evidence_summary_link,
      evs_introduction_link: evs_introduction_link,
      evs_methods_link: evs_methods_link,
      evs_results_link: evs_results_link,
      evs_discussion_link: evs_discussion_link,
      evs_conclusions_link: evs_conclusions_link,
      evs_tables_figures_link: evs_tables_figures_link,
      disposition_of_comments_link: disposition_of_comments_link,
      srdr_data_link: srdr_data_link,
      most_previous_version_srdr_link: most_previous_version_srdr_link,
      most_previous_version_full_report_link: most_previous_version_full_report_link,
      overall_purpose_of_review: overall_purpose_of_review,
      type_of_review: type_of_review,
      level_of_analysis: level_of_analysis,
    )

    funding_sources = [
      "Agency for Healthcare Research and Quality (AHRQ), Rockville, MD (Contract No. 290-2015-00002-I).",
      "The Patient Centered Outcomes Research Institute (PCORI) funded the report (PCORI Publication No. 2018-SR-03)."
    ]

    sd_meta_datum.funding_sources << funding_sources.map { |source| FundingSource.find_or_create_by(name: source) }

    key_questions = [
      "Key Question 1: What are the benefits and harms of nonpharmacological treatments of UI in women, and how do they compare with each other?\n 1a. How do nonpharmacological treatments affect UI, UI severity and frequency, and quality of life when compared with no active treatment?\n 1b. What are the harms from nonpharmacological treatments when compared with no active treatment?\n 1c. What is the comparative effectiveness of nonpharmacological treatments when compared with each other?\n 1d. What are the comparative harms from nonpharmacological treatments when compared with each other?\n 1e. Which patient characteristics, including age, type of UI, severity of UI, baseline diseases that affect UI, adherence to treatment recommendations, and comorbidities, modify the effects of nonpharmacological treatments on patient outcomes, including continence, quality of life, and harms?",
      "Key Question 2: What are the benefits and harms of pharmacological treatments of UI in women, and how do they compare with each other?\n2a. How do pharmacological treatments affect UI, UI severity and frequency, and quality of life when compared with no active treatment?\n2b. What are the harms from pharmacological treatments when compared with no active treatment?\n2c. What is the comparative effectiveness of pharmacological treatments when compared with each other?\n2d. What are the comparative harms from pharmacological treatments when compared with each other?\n2e. Which patient characteristics, including age, type of UI, severity of UI, baseline diseases that affect UI, adherence to treatment recommendations, and comorbidities, modify the effects of the pharmacological treatments on patient outcomes, including continence, quality of life, and harms?",
      "Key Question 3: What are the comparative benefits and harms of nonpharmacological versus pharmacological treatments of UI in women?\n3a. What is the comparative effectiveness of nonpharmacological treatments when compared with pharmacological treatments?\n3b. What are the comparative harms of nonpharmacological treatments when compared with pharmacological treatments?\n3c. Which patient characteristics, including age, type of UI, severity of UI, baseline diseases that affect UI, adherence to treatment recommendations, and comorbidities, modify the comparative effectiveness of nonpharmacological and pharmacological treatments on patient outcomes, including continence, quality of life, and harms?",
      "Key Question 4: What are the benefits and harms of combined nonpharmacological and pharmacological treatment of UI in women?\n4a. How do combined nonpharmacological and pharmacological treatments affect UI, UI severity and frequency, and quality of life when compared with no active treatment?\n4b. What are the harms from combined nonpharmacological and pharmacological treatments when compared with no active treatment?\n4c. What is the comparative effectiveness of combined nonpharmacological and pharmacological treatments when compared with nonpharmacological treatment alone?\n4d. What is the comparative effectiveness of combined nonpharmacological and pharmacological treatments when compared with pharmacological treatment alone?\n4e. What is the comparative effectiveness of combined nonpharmacological and pharmacological treatments when compared with other combined nonpharmacological and pharmacological treatments?\n4f. What are the comparative harms from combined nonpharmacological and pharmacological treatments when compared with nonpharmacological treatment alone, pharmacological treatment alone, or other combined treatments?\n4g. Which patient characteristics, including age, type of UI, severity of UI, baseline diseases that affect UI, adherence to treatment recommendations, and comorbidities, modify the effects of combined nonpharmacological and pharmacological treatments on patient outcomes, including continence, quality of life, and harms?",
      "Contextual Question: How do women with UI that is amenable to nonsurgical treatments perceive treatment success?"
    ]

    sd_meta_datum.key_questions << key_questions.map { |key_question| KeyQuestion.find_or_create_by(name: key_question) }

    sd_analytic_frameworks = [
      {
        text: "To guide the assessment of studies that examine the effect of nonpharmacological and pharmacological interventions on clinical and patient-centered outcomes and adverse events in women with UI, the analytic framework (Figure 1) maps the specific linkages associating the populations, interventions, modifying factors, and outcomes of interest. The analytic framework depicts the chains of logic that evidence must support to link the studied interventions to outcomes of interest.",
        figure: "https://www.ncbi.nlm.nih.gov/books/NBK534619/bin/ch2f1.jpg"
      }
    ]

    sd_meta_datum.sd_analytic_frameworks << sd_analytic_frameworks.map { |sd_analytic_framework| SdAnalyticFramework.find_or_create_by(name: sd_analytic_framework[:text], sd_meta_datum_id: sd_meta_datum.id) }
    sd_meta_datum.sd_analytic_frameworks.first.pictures.attach(io: File.open(Rails.root.join('demo_temp', 'ch2f1.jpg')), filename: 'ch2f1.jpg', content_type: 'image/png')

    picods = [
      {
        kq: key_questions.first,
        type: 'Populations',
        text: "Population: Based on stakeholder input, we highlighted four specific subpopulations of interest (women athletes and those engaging in high-impact physical activities, older women, women in the military or veterans, and racial and ethnic minorities). Studies that either focused on these subpopulations or provide relevant subgroup data are summarized separately.\nIn addition, we applied stricter rules about the exclusion criteria, allowing only up to 10 percent of study participants to be among the excluded populations (e.g., men, children, “dry” overactive bladder [without incontinence], institutionalized people); the 2012 AHRQ review allowed up to 25 percent of participants to be men. Studies included in the 2012 AHRQ review that included between 10 and 25 percent men were excluded from the current review. We also excluded other studies included in the 2012 AHRQ review that did not meet either their or our criteria."
      },
      {
        kq: key_questions.first,
        type: 'Interventions/Exposures',
        text: "Interventions: The list of eligible nonpharmacological interventions is the same as in the 2012 AHRQ review, although we have added some specific interventions to the list that were not explicitly listed a priori in the 2012 AHRQ review (e.g., bladder training). Similarly, the list of pharmacological treatments is more complete than the a priori list in the 2012 AHRQ review; additional drugs known to be in use have been added, including calcium channel blockers, TRPV1 (transient receptor potential cation channel subfamily V member 1) antagonists, additional antidepressant classes, and mirabegron (a beta-3 adeno-receptor agonist). Although not listed a priori in the 2012 AHRQ review, calcium channel blockers and resiniferatoxin (a TRPV1 antagonist) were included in the original review. No studies of selective serotonin or serotonin-norepinephrine reuptake inhibitors (SSRI or SNRI) antidepressants or of mirabegron were included in the AHRQ 2012 review."
      },
      {
        kq: key_questions.first,
        type: 'Comparators',
        text: "Comparators: No changes are made from the 2012 AHRQ review."
      },
      {
        kq: key_questions.first,
        type: 'Outcomes',
        text: "Outcomes: All outcomes reported in the 2012 AHRQ review’s eligibility criteria (Appendix D of that document) are included in this update, except for urodynamic testing, which is used in practice only for diagnosis, not for followup outcome assessment. As per the 2012 AHRQ review, we included only categorical urinary incontinence outcomes (e.g., cure, improvement). Noneligible outcomes for the current review that were extracted for the 2012 AHRQ review were omitted from this report. For quality of life outcomes, we included both categorical and continuous (i.e., score or scale) outcomes, although the extraction and summarization of these were handled in a more summary manner than in the 2012 AHRQ review. Adverse events were also included. We searched studies for all patient-centered outcomes identified from the contextual question on how patients define outcome success."
      },
      {
        kq: key_questions.first,
        type: 'Study Designs',
        text: "Study Design, Timing, Setting: No substantive changes are made from the 2012 AHRQ review, except that the eligibility criteria were applied more completely (e.g., small single group studies included in the 2012 AHRQ review were omitted)."
      },
      {
        kq: key_questions.first,
        type: 'Settings',
        text: "Study Design, Timing, Setting: No substantive changes are made from the 2012 AHRQ review, except that the eligibility criteria were applied more completely (e.g., small single group studies included in the 2012 AHRQ review were omitted)."
      }
    ]

    sd_meta_datum.sd_picods << picods.map { |picod| SdPicod.find_or_create_by(name: picod[:text], sd_meta_datum_id: sd_meta_datum.id, p_type: picod[:type]) }

    literature_flows = [
      {
        text: "Study Design, Timing, Setting: No substantive changes are made from the 2012 AHRQ review, except that the eligibility criteria were applied more completely (e.g., small single group studies included in the 2012 AHRQ review were omitted).",
        figure: "https://www.ncbi.nlm.nih.gov/books/NBK534614/bin/ch5f1.jpg"
      }
    ]

    sd_meta_datum.sd_prisma_flows << literature_flows.map { |flow| SdPrismaFlow.find_or_create_by(name: flow[:text], sd_meta_datum_id: sd_meta_datum.id) }
    sd_meta_datum.sd_prisma_flows.first.pictures.attach(io: File.open(Rails.root.join('demo_temp', 'ch5f1.jpg')), filename: 'ch5f1.jpg', content_type: 'image/png')

    sd_summary_of_evidences = [
      {
        text: "Risk of bias across all studies is presented in Figure 5. Full risk of bias evaluations by study are given in Appendix D.\nFigure 5. Risk of bias for all studies with urinary incontinence or quality of life outcomes",
        type: "Risk of Bias",
        figure: "https://www.ncbi.nlm.nih.gov/books/NBK534614/bin/ch5f2.jpg"
      },
      {
        text: "Table 27. Evidence profile for nonpharmacological and pharmacological interventions for urinary incontinence",
        type: "Strength of Evidence",
        figure: ""
      }
    ]

    sd_meta_datum.sd_summary_of_evidences << sd_summary_of_evidences.map { |evidence| SdSummaryOfEvidence.find_or_create_by(name: evidence[:text], soe_type: evidence[:type], sd_key_question: sd_meta_datum.sd_key_questions.first, sd_meta_datum_id: sd_meta_datum.id) }
    sd_meta_datum.sd_summary_of_evidences.first.pictures.attach(io: File.open(Rails.root.join('demo_temp', 'ch5f2.jpg')), filename: 'ch5f2.jpg', content_type: 'image/png')

    search_strategies = [
      {
        database: "PubMed",
        date: "11/28/17",
        limits: "2011-current",
        terms: "((\"Urinary Bladder, Overactive\"[Mesh] OR \"Urinary Incontinence\"[Mesh] OR \"Enuresis\"[Mesh] OR overactive bladder OR ((bladder or urine) AND incontinen*) OR enuresis OR nocturia OR \"Nocturia\"[Mesh] OR ((bladder or urine or urina*) and (overactive or incontinence or urgent or urgency or frequent or frequency or detrusor or leak*)) OR detrusor instability OR \"Urinary Bladder, Neurogenic\"[Mesh] OR (bladder AND (neurogen* or neurologic*)) OR \"Urinary Incontinence, Urge\"[Mesh] OR \"Urinary Incontinence, Stress\"[Mesh] OR ((urine OR urina* or bladder*) and urge*))\nAND\n(“Urinary Incontinence/Radiotherapy”[Mesh] OR “Urinary Incontinence/Rehabilitation”[Mesh] OR “Urinary Incontinence/Surgery”[Mesh] OR “Urinary Incontinence/Therapy”[Mesh] OR “Urinary Incontinence/Diet Therapy”[Mesh] OR “Urinary Incontinence/Nursing”[Mesh] OR “Urinary Incontinence/Drug”[Mesh] OR ((non pharmacologic* or nonpharmacologic*) AND “Treatment Outcome”[Mesh]) OR mirabegron OR \"Adrenergic beta-3 Receptor Agonists\"[Mesh] OR Resiniferatoxin OR \"Botulinum Toxins\"[Mesh] OR \"Botulinum Toxins, Type A\"[Mesh] OR botulinum OR botox OR estrogen* OR \"Estrogens\"[Mesh] OR Antimuscarinics OR oxybutynin chloride OR trospium chloride OR darifenacin OR solifenacin succinate OR fesoterodine OR tolterodine OR propiverine OR \"Calcium Channel Blockers\"[Mesh] OR Calcium Channel Blocker* OR nimodipine OR TRPV1 antagonists OR resiniferatoxin OR Tricyclic antidepressant* OR Tricyclic anti-depressant OR \"Antidepressive Agents, Tricyclic\"[Mesh] OR imipramine OR Beta 3 adeno-receptor agonists OR mirabegron OR \"Neuromuscular Agents\"[Mesh] OR neuromuscular agents OR ((pelvic floor or bladder) AND (train* or exercise or physical therapAy)) OR kegel OR \"Physical Therapy Modalities\"[Mesh] OR physiotherapy OR biofeedback OR \"Biofeedback, Psychology\"[Mesh] OR electric* stimulation OR “Electric Stimulation\"[Mesh] OR nerve stimulation OR “Transcutaneous Electric Nerve Stimulation\"[Mesh] OR stoller OR “Electrodes, Implanted\"[Mesh] OR vesical pacing OR interstim OR “fluid therapy\"[Mesh] OR (fluid AND (therapy or manage*)) OR urge suppression OR “Behavior Therapy”[Mesh] OR ((behavior* or behaviour*) AND (therapy or modif* or treat*)) OR “hypnosis”[Mesh] OR (hypnosis or hypnotherapy) OR “Drinking Behavior”[Mesh] OR “Complementary Therapies”[Mesh] OR ((alternative or complementary) AND (therapy or treatment)) OR “diet”[Mesh] OR diet OR dietary OR Vaginal cone* OR bladder support* OR (Urethra* AND (Plug or patch)) OR Pessar* OR Magnetic stimulation OR \"Magnetic Field Therapy\"[Mesh] OR Urethral bulking OR ((transurethral or periurethral) AND injection*) OR Posterior tibial nerve stimulation OR neuromodulation OR Coaptite OR (Vaginal AND (cone* OR weight*)) OR Impressa OR Macroplastique implants OR Milnacipran OR Savella OR Trospium OR Sanctura OR Onabotulinum toxin A OR Botox OR Paroxetine OR Paxil OR Mirabegron OR Myrbetriq OR solifenacin succinate OR vesicare OR Amitriptyline OR Elavil OR Rimabotulinum toxin B OR Myobloc OR Fluoxetine OR Prozac OR Duloxetine OR Cymbalta OR Citalopram OR Celexa OR Escitalopram OR Lexapro OR Levomilnacipran OR Fetzima OR AbobotulinumtoxinA OR Dysport OR oxybutynin chloride OR Ditropan OR Fluvoxamine OR Luvox CR OR Imipramine OR Tofranil OR Nortriptyline OR Pamelorl OR Clomipramine OR Anafranil OR IncobotulinumtoxinA OR Xeomin OR Doxepin OR Silenor OR Protriptyline OR Vivactil OR Trimipramine OR Surmontil OR 5-HT2 receptor antagonist OR Doxepin OR Silenor OR Sertraline OR Zoloft OR Tolterodine OR Detrol OR Desipramine OR Pertofrane OR\n A-1\nDesipramine OR Norpramin OR Darifenacin OR Enablex OR Desvenlafaxine OR Pristiq OR Topical estrogen OR premarin OR synthetic conjugated estrogens)\nAND\n(\"Cohort Studies\"[Mesh] OR cohort OR \"Clinical Trial\" [Publication Type] OR \"Clinical Trials as Topic\"[Mesh] OR (follow-up or followup) OR longitudinal OR \"Placebos\"[Mesh] OR placebo* OR \"Research Design\"[Mesh] OR \"Evaluation Studies\" [Publication Type] OR \"Evaluation Studies as Topic\"[Mesh] OR \"Comparative Study\" [Publication Type] OR ((comparative or Intervention) AND study) OR Intervention Stud* OR pretest* OR pre test* OR posttest* OR post test* OR prepost* OR pre post* OR “before and after” OR interrupted time* OR time serie* OR intervention* OR ((\"quasi-experiment*\" OR quasiexperiment* OR quasi or experimental) and (method or study or trial or design*)) OR \"Case-Control Studies\"[Mesh] OR (case and control) OR \"Random Allocation\"[Mesh] OR \"Double-Blind Method\"[Mesh] OR \"Single-Blind Method\"[Mesh] OR random* OR \"Clinical Trial\" [Publication Type] OR \"Clinical Trials as Topic\"[Mesh] OR \"Placebos\"[Mesh] OR placebo OR ((clinical OR controlled) and trial*) OR ((singl* or doubl* or trebl* or tripl*) and (blind* or mask*)) OR rct OR crossover OR cross-over OR cross-over))\nNOT\n(“addresses”[pt] or “autobiography”[pt] or “bibliography”[pt] or “biography”[pt] or “case reports”[pt] or “congresses”[pt] or “dictionary”[pt] or “directory”[pt] or “editorial”[pt] or “festschrift”[pt] or “government publications”[pt] or “historical article”[pt] or “interview”[pt] or “lectures”[pt] or “legal cases”[pt] or “legislation”[pt] or “news”[pt] or “newspaper article”[pt] or “patient education handout”[pt] or “periodical index”[pt] or \"comment on\" or (\"Animals\"[Mesh] NOT \"Humans\"[Mesh]) OR rats[tw] or cow[tw] or cows[tw] or chicken*[tw] or horse[tw] or horses[tw] or mice[tw] or mouse[tw] or bovine[tw] or sheep or ovine or murinae or (\"Men\"[Mesh] NOT \"Women\"[Mesh]) OR \"Pregnant Women\"[Mesh])"
      },
      {
        database: "Cochrane",
        date: "11/28/17",
        limits: "2011-",
        terms: "((mh \"Urinary Bladder, Overactive\" OR mh \"Urinary Incontinence\" OR mh Enuresis OR overactive bladder OR ((bladder or urine) AND incontinen*) OR enuresis OR nocturia OR mh Nocturia OR ((bladder or urine) and (overactive or incontinence or urgent or urgency or frequent or frequency or detrusor or leak*)) OR detrusor instability OR mh \"Urinary Bladder, Neurogenic\" OR (bladder AND (neurogen* or neurologic*)) OR mh \"Urinary Incontinence, Urge\" OR mh \"Urinary Incontinence, Stress\" OR ((urine OR urina* or bladder*) and urge*)) NOT ((mh Men NOT mh Women) OR mh \"Pregnant Women\"))\nAND\n(mh “Urinary Incontinence/Radiotherapy” OR mh “Urinary Incontinence/Rehabilitation” OR mh “Urinary Incontinence/Surgery” OR mh “Urinary Incontinence/Therapy” OR mh “Urinary Incontinence/Diet Therapy” OR mh “Urinary Incontinence/Nursing” OR “Urinary Incontinence/Drug” OR ((non pharmacologic* or nonpharmacologic*) AND mh “Treatment Outcome”) OR mirabegron OR mh \"Adrenergic beta-3 Receptor Agonists\" OR Resiniferatoxin OR mh \"Botulinum Toxins\" OR mh \"Botulinum Toxins, Type A\" OR botulinum OR botox OR estrogen* OR mh Estrogens OR Antimuscarinics OR oxybutynin chloride OR trospium chloride\n A-2\nOR darifenacin OR solifenacin succinate OR fesoterodine OR tolterodine OR propiverine OR mh \"Calcium Channel Blockers\" OR Calcium Channel Blocker* OR nimodipine OR TRPV1 antagonists OR resiniferatoxin OR Tricyclic antidepressant* OT Tricyclic anti-depressant OR mh \"Antidepressive Agents, Tricyclic\" OR imipramine OR Beta 3 adeno-receptor agonists OR mirabegron OR mh \"Neuromuscular Agents\" OR neuromuscular agents OR ((pelvic floor or bladder) AND (train* or exercise* or physical therap*)) OR kegel OR mh \"Physical Therapy Modalities\" OR physiotherapy OR biofeedback OR mh \"Biofeedback, Psychology\" OR electric* stimulation OR mh “Electric Stimulation\" OR nerve stimulation OR mh “Transcutaneous Electric Nerve Stimulation\" OR stoller OR mh “Electrodes, Implanted\" OR (vesical pacing or interstim) OR mh “fluid therapy\" OR (fluid AND (therapy or manage*)) OR urge suppression OR mh “Behavior Therapy” OR ((behavior* or behaviour*) AND (therapy or modif* or treat*)) OR mh hypnosis OR (hypnosis or hypnotherapy) OR mh “Drinking Behavior” OR mh “Complementary Therapies” OR ((alternative or complementary) AND (therapy or treatment)) OR mh diet OR diet OR mh “Quality of Life” OR biofeedback OR bladder support* OR impressa OR (Urethra* AND (Plug or patch)) OR Magnetic stimulation OR mh \"Magnetic Field Therapy\" OR Urethral bulking OR ((transurethral or periurethral) AND injection*) OR Pessar* OR Posterior tibial nerve stimulation OR neuromodulation OR Coaptite OR (Vaginal AND (cone* OR weight*)) OR Impressa OR Macroplastique implants OR Milnacipran OR Savella OR Trospium OR Sanctura OR Onabotulinum toxin A OR Botox OR Paroxetine OR Paxil OR Mirabegron OR Myrbetriq OR solifenacin succinate OR vesicare OR Amitriptyline OR Elavil OR Rimabotulinum toxin B OR Myobloc OR Fluoxetine OR Prozac OR Duloxetine OR Cymbalta OR Citalopram OR Celexa OR Escitalopram OR Lexapro OR Levomilnacipran OR Fetzima OR AbobotulinumtoxinA OR Dysport OR oxybutynin chloride OR Ditropan OR Fluvoxamine OR Luvox CR OR Imipramine OR Tofranil OR Nortriptyline OR Pamelorl OR Clomipramine OR Anafranil OR IncobotulinumtoxinA OR Xeomin OR Doxepin OR Silenor OR Protriptyline OR Vivactil OR Trimipramine OR Surmontil OR 5-HT2 receptor antagonist OR Doxepin OR Silenor OR Sertraline OR Zoloft OR Tolterodine OR Detrol OR Desipramine OR Pertofrane OR Desipramine OR Norpramin OR Darifenacin OR Enablex OR Desvenlafaxine OR Pristiq OR Topical estrogen OR premarin OR synthetic conjugated estrogens)"
      },
      {
        database: "Embase",
        date: "11/28/17",
        limits: "",
        terms: "urinary AND ('incontinence'/exp OR incontinence) OR 'enuresis'/exp OR enuresis OR overactive AND ('bladder'/exp OR bladder) OR 'nocturia'/exp OR nocturia AND nonpharmacological OR 'non pharmacological' OR 'mirabegron'/exp OR mirabegron OR 'beta 3 adrenergic receptor stimulating agent'/exp OR 'beta 3 adrenergic receptor stimulating agent' OR 'resiniferatoxin'/exp OR 'resiniferatoxin' OR botulinum AND ('toxins'/exp OR toxins) OR botox OR 'estrogen'/exp OR 'estrogen' OR antimuscarinics OR 'oxybutynin' OR trospium AND chloride OR darifenacin OR fesoterodine OR tolterodine OR propiverine OR solifenacin AND succinate OR 'calcium channel blocking agent'/exp OR 'calcium channel blocking agent' OR nimodipine OR trpv1 AND antagonists OR 'resiniferatoxin' OR 'antidepressant agent' OR imipramine OR 'muscle relaxant agent' OR 'physiotherapy'/exp OR physiotherapy OR 'biofeedback'/exp OR biofeedback OR electric AND ('stimulation'/exp OR stimulation) OR 'nerve'/de AND 'stimulation'/de OR 'fluid therapy' OR urge AND suppression OR 'behavior therapy' OR 'behavior therapy'/de OR\n'hypnosis'/exp OR 'hypnosis' OR 'alternative medicine'/exp OR 'alternative medicine' OR 'diet'/exp OR 'diet' OR vaginal AND cone OR 'magnetic stimulation'/de OR 'magnetic stimulation' OR urethral AND bulking OR 'vagina pessary' OR impressa OR milnacipran OR savella OR trospium OR sanctura OR paroxetine OR paxil OR mirabegron OR myrbetriq OR 'solifenacin succinate' OR vesicare OR amitriptyline OR elavil OR 'rimabotulinum toxin b' OR myobloc OR fluoxetine OR prozac OR duloxetine OR cymbalta OR citalopram OR celexa OR escitalopram OR lexapro OR levomilnacipran OR fetzima OR abobotulinumtoxina OR dysport OR oxybutynin AND chloride OR ditropan OR fluvoxamine OR luvox OR imipramine OR tofranil OR nortriptyline OR pamelorl OR clomipramine OR anafranil OR incobotulinumtoxina OR xeomin OR protriptyline OR vivactil OR trimipramine OR surmontil OR doxepin OR silenor OR sertraline OR zoloft OR tolterodine OR detrol OR pertofrane OR desipramine OR norpramin OR darifenacin OR enablex OR desvenlafaxine OR pristiq OR premarin AND 'cohort analysis' OR 'controlled clinical trial'/exp OR 'controlled clinical trial' OR 'evaluation study' OR 'comparative study' OR 'intervention study' OR 'case control study' OR 'randomized controlled trial' OR 'crossover procedure' AND ([article]/lim OR [article in press]/lim OR [conference abstract]/lim OR [conference paper]/lim) AND [female]/lim AND [humans]/lim AND [2011- 2017]/py"
      },
      {
        database: "CINAHL/PsycINFO",
        date: "11/28/17",
        limits: "",
        terms: "((\"Urinary Bladder, Overactive\" OR mh \"Urinary Incontinence\" OR mh Enuresis OR overactive bladder OR ((bladder or urine) AND incontinen*) OR enuresis OR nocturia OR mh Nocturia OR ((bladder or urine) and (overactive or incontinence or urgent or urgency or frequent or frequency or detrusor or leak*)) OR detrusor instability OR mh \"Urinary Bladder, Neurogenic\" OR (bladder AND (neurogen* or neurologic*)) OR mh \"Urinary Incontinence, Urge\" OR mh \"Urinary Incontinence, Stress\" OR ((urine OR urina* or bladder*) and urge*)) NOT ((mh Men NOT mh Women) OR mh \"Pregnant Women\"))\nAND\n(mirabegron OR Resiniferatoxin OR \"Botulinum Toxins\" OR botulinum OR botox OR estrogen* OR Antimuscarinics OR oxybutynin chloride OR trospium chloride OR darifenacin OR solifenacin succinate OR fesoterodine OR tolterodine OR propiverine OR Calcium Channel Blocker* OR nimodipine OR TRPV1 antagonists OR resiniferatoxin OR Tricyclic antidepressants OR imipramine OR Beta 3 adeno-receptor agonists OR mirabegron OR \"Neuromuscular Agents\" OR neuromuscular agents OR ((pelvic floor or bladder) AND (train* or exercise or physical therapy)) OR kegel OR \"Physical Therapy\" OR physiotherapy OR biofeedback OR electric* stimulation OR nerve stimulation OR “Transcutaneous Electric Nerve Stimulation\" OR stoller OR vesical pacing OR interstim OR (fluid AND (therapy or manage*)) OR urge suppression OR ((behavior* or behaviour*) AND (therapy or modif* or treat*)) OR hypnosis OR hypnotherapy) OR “Drinking Behavior” OR ((alternative or complementary) AND (therapy or treatment)) OR diet OR “Quality of Life” OR biofeedback OR Vaginal cone* OR bladder support* OR impressa OR (Urethra* AND (Plug OR patch)) OR Magnetic stimulation OR Magnetic Field Therapy OR Urethral bulking OR ((transurethral or periurethral) AND injection*) OR Intravaginal electrical stimulation OR Magnetic stimulation OR Pessar* OR Posterior tibial nerve stimulation OR neuromodulation OR Coaptite OR Macroplastique implants OR Milnacipran OR Savella OR Trospium OR Sanctura OR Paroxetine OR Paxil OR Mirabegron OR Myrbetriq OR solifenacin succinate OR vesicare OR Amitriptyline OR Elavil OR Rimabotulinum toxin B OR Myobloc OR Fluoxetine OR Prozac OR Duloxetine OR\nCymbalta OR Citalopram OR Celexa OR Escitalopram OR Lexapro OR Levomilnacipran OR Fetzima OR AbobotulinumtoxinA OR Dysport OR oxybutynin chloride OR Ditropan OR Fluvoxamine OR Luvox CR OR Imipramine OR Tofranil OR Nortriptyline OR Pamelorl OR Clomipramine OR Anafranil OR IncobotulinumtoxinA OR Xeomin OR Doxepin OR Silenor OR Protriptyline OR Vivactil OR Trimipramine OR Surmontil OR Doxepin OR Silenor OR Sertraline OR Zoloft OR Tolterodine OR Detrol OR Desipramine OR Pertofrane OR Desipramine OR Norpramin OR Darifenacin OR Enablex OR Desvenlafaxine OR Pristiq OR Topical estrogen OR premarin OR synthetic conjugated estrogens)"
      },
      {
        database: "ClinicalTrials.gov",
        date: "6/13/17",
        limits: "limit to adult and senior\nlimit to studies with female participants\nlimit first received date to 1/1/2011 to 12/31/2017\nSearch for retracted studies returned no matches to the list of included studies (1/10/18)",
        terms: "urinary incontinence OR overactive bladder OR enuresis OR nocturia OR detrusor instability"
      }
    ]

    sd_meta_datum.sd_search_strategies << search_strategies.map { |strategy| SdSearchStrategy.find_or_create_by(sd_search_database: SdSearchDatabase.find_or_create_by(name: strategy[:database]), date_of_search: strategy[:date], search_limits: strategy[:limits], search_terms: strategy[:terms], sd_meta_datum_id: sd_meta_datum.id) }
  end
end