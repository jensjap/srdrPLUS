# Seed data essential to get things rolling.
module SeedData
  def self.extended(object)
    object.instance_exec do
      # Turn off paper_trail.
      PaperTrail.enabled = false

      # Roles.
      Role.create([
        { name: 'Leader'},
        { name: 'Consolidator'},
        { name: 'Contributor'},
        { name: 'Auditor'}
      ])

      # Frequency.
      Frequency.create([
        { name: 'Daily' },
        { name: 'Weekly' },
        { name: 'Monthly' },
        { name: 'Annually' }
      ])

      # MessageTypes.
      @totd = MessageType.create(name: 'Tip Of The Day', frequency: Frequency.first)
      MessageType.create([
        { name: 'General Announcement', frequency: Frequency.first },
        { name: 'Maintenance Announcement', frequency: Frequency.first }
      ])

      # ActionTypes.
      ActionType.create([
        { name: 'Create' },
        { name: 'Destroy' },
        { name: 'Update' },
        { name: 'New' },
        { name: 'Index' },
        { name: 'Show' },
        { name: 'Edit' }
      ])

      # TaskTypes.
      TaskType.create(name: 'Perpetual')
      TaskType.create(name: 'Pilot')
      TaskType.create(name: 'Advanced')
      TaskType.create(name: 'Conflict')

      # ConsensusTypes.
      ConsensusType.create([
        { name: 'Yes' },
        { name: 'No' },
        { name: 'Maybe' },
        { name: 'Conflict' }
      ])

      # Type1Types.
      Type1Type.create([
        { name: 'Categorical' },
        { name: 'Continuous' },
        { name: 'Time to Event' },
        { name: 'Adverse Event' }
      ])

      # ResultStatisticSectionTypes.
      @descriptive_statistics_result_statistic_section_type  = ResultStatisticSectionType.create(name: 'Descriptive Statistics')
      @between_arm_comparisons_result_statistic_section_type = ResultStatisticSectionType.create(name: 'Between Arm Comparisons')
      @within_arm_comparisons_result_statistic_section_type  = ResultStatisticSectionType.create(name: 'Within Arm Comparisons')
      @net_change_result_statistic_section_type              = ResultStatisticSectionType.create(name: 'NET Change')

      # Measures.
      @n_analyzed = Measure.create(name: 'N Analyzed')
      @counts     = Measure.create(name: 'Counts')
      @proportion = Measure.create(name: 'Proportions')
      @percentage = Measure.create(name: 'Percentage')

      # Default measures for each ResultStatisticSectionType.
      @descriptive_statistics_result_statistic_section_type.measures << @n_analyzed
      @descriptive_statistics_result_statistic_section_type.measures << @counts

      #!!! While this was requested...it is now being added before a comparison is even present.
      #    We need to change the code to add default measures only when the comparison is present
      #    for the case of BAC, WAC and NET.
      #@within_arm_comparisons_result_statistic_section_type.measures << @n_analyzed

      # Extraction Forms Projects Section Types.
      ExtractionFormsProjectsSectionType.create(
        [
          { name: 'Type 1' },
          { name: 'Type 2' },
          { name: 'Results' },
        ]
      )

      # Sections.
      Section.create(
        [
          { name: 'Design Details', default: true },
          { name: 'Arms', default: true },
          { name: 'Arm Details', default: true },
          { name: 'Sample Characteristics', default: true },
          { name: 'Outcomes', default: true },
          { name: 'Outcome Details', default: true },
          { name: 'Risk of Bias Assessment', default: true },
          { name: 'Results', default: true }
        ]
      )

      # Seed QuestionRowColumnType.
      QuestionRowColumnType.create(
        [
          { name: 'text' },
          { name: 'numeric' },
          { name: 'numeric_range' },
          { name: 'scientific' },
          { name: 'checkbox' },
          { name: 'dropdown' },
          { name: 'radio' },
          { name: 'select2_single' },
          { name: 'select2_multi' }
        ]
      )

      # Seed QuestionRowColumnFieldOption.
      QuestionRowColumnOption.create(
        [
          { name: 'answer_choice' }, # For multiple-choice: checkbox, radio, dropdown
          { name: 'min_length' },    # For text
          { name: 'max_length' },    # For text
          { name: 'min_value' },     # For scientific, numerical
          { name: 'max_value' },     # For scientific, numerical
          { name: 'coefficient' },   # For scientific
          { name: 'exponent' }       # For scientific
        ]
      )

      # Seed Extraction Form Types.
      ExtractionFormsProjectType.create(name: 'Standard')
      ExtractionFormsProjectType.create(name: 'Diagnostic Test')

      # Timepoint Names.
      TimepointName.create(name: 'Baseline')
      TimepointName.create(name: '1',  unit: 'week')
      TimepointName.create(name: '2',  unit: 'weeks')
      TimepointName.create(name: '3',  unit: 'weeks')
      TimepointName.create(name: '4',  unit: 'weeks')
      TimepointName.create(name: '5',  unit: 'weeks')
      TimepointName.create(name: '6',  unit: 'weeks')
      TimepointName.create(name: '7',  unit: 'weeks')
      TimepointName.create(name: '8',  unit: 'weeks')
      TimepointName.create(name: '9',  unit: 'weeks')
      TimepointName.create(name: '10', unit: 'weeks')
      TimepointName.create(name: '1',  unit: 'month')
      TimepointName.create(name: '2',  unit: 'months')
      TimepointName.create(name: '3',  unit: 'months')
      TimepointName.create(name: '4',  unit: 'months')
      TimepointName.create(name: '5',  unit: 'months')
      TimepointName.create(name: '6',  unit: 'months')
      TimepointName.create(name: '7',  unit: 'months')
      TimepointName.create(name: '8',  unit: 'months')
      TimepointName.create(name: '9',  unit: 'months')
      TimepointName.create(name: '10', unit: 'months')
      TimepointName.create(name: '1',  unit: 'year')
      TimepointName.create(name: '2',  unit: 'years')
      TimepointName.create(name: '3',  unit: 'years')
      TimepointName.create(name: '4',  unit: 'years')
      TimepointName.create(name: '5',  unit: 'years')
      TimepointName.create(name: '6',  unit: 'years')
      TimepointName.create(name: '7',  unit: 'years')
      TimepointName.create(name: '8',  unit: 'years')
      TimepointName.create(name: '9',  unit: 'years')
      TimepointName.create(name: '10', unit: 'years')

      # Population Names.
      PopulationName.create(name: 'All Participants', description: 'All patients enrolled in this study.')

      # Turn on paper_trail.
      PaperTrail.enabled = true

    end
  end
end

# Sample Data.
module SeedDataExtended
  def self.extended(object)
    project_titles = [
      ['Definition of Treatment-Resistant Depression in the Medicare Population', 'The purpose of this technology assessment is to review the current definitions of treatment-resistant depression (TRD), to assess how closely current TRD treatment studies fit the most common definition, and to suggest how to improove TRD treatment research.'],
      ['Diet-Related Fibers and Human Health Outcomes, Version 4.0', 'The objectives of this database are to: 1. Systematically compile and provide access to primary, English-language, peer-reviewed science linking dietary fiber intake in humans to one or more of 10 potential health benefits 2. Proovide researchers with a tool to understand how different fibers are characterized in studies 3. Facilitate researchers in identifying gaps in the current research 4. Create a database to serve as a starting foundation of primary human literature for conducting evidence-based reviews and meta-analyses 5. Efficiently assist researchers in identifying fibers of interest. This database should serve as a foundation for future work. Specific inclusion and exclusion criteria, detailed in the user manual, were applied in determining database eligibility; thus, this database is not intended to serve as a sole source for identifying all possible fiber literature for the purposes of conducting a meta-analysis or systematic review. This database contains Population, Intervention, Comparator, and Outcome (PICO) data to help users formulate and narrow the focus of their research question. It is expected that secondary searches will be conducted to augment this database.'],
      ['Role of Bronchial Thermoplasty in Management of Asthma', 'This review assesses the role of bronchial thermoplasty (BT) in adults with asthma.'],
      ['Interventions for central serous chorioretinopathy: a network meta-analysis', 'The purpose of this form is to abstract data from reports corresponding to a study included in a systematic review.'],
      ['Management of Suspected Opioid Overdose with Naloxone by Emergency Medical Services Personnel [Entered Retrospectively]', 'Objectives. To compare different routes, doses, and dosing strategies of naloxone administration for suspected opioid overdose by emergency medical services (EMS) personnel in field settings, and to compare effects of transport to a health care facility versus nontransport following successful reversal of opioid overdose with naloxone. Methods. Four databases were searched through March 2017. Additional studies were identified from reference lists and technical experts. We included randomized controlled trials (RCTs) and cohort studies comparing different naloxone routes of administration, doses, or dosing strategies and on effects of transport or nontransport following successful reversal of opioid overdose with naloxone. Two investigators independently applied prespecified criteria to rate study quality. The strength of evidence was determined based on the overall risk of bias, consistency, directness, precision, and reporting bias. Results. Twelve studies met inclusion criteria. Three RCTs and four cohort studies compared different routes of administration. Two trials compared intranasal (IN) with intramuscular (IM) naloxone administration (strength of evidence [SOE] for all outcomes: low). While 2 mg of a higher-concentration formulation of IN naloxone (2 mg/1 mL) is similar in efficacy to 2 mg of IM naloxone, 2 mg of a lower-concentration formulation of IN naloxone (2 mg/5 mL formulation) is less effective than the same dose IM but associated with decreased risk of agitation and/or irritation. The 2 mg/5 mL formulation of IN naloxone studied in this trial is lower than concentrations used in the United States. In both trials, IN naloxone was associated with increased likelihood of rescue naloxone use. Although one RCT and two observational studies evaluated intravenous (IV) versus IN naloxone, evidence was insufficient to determine comparative benefits and harms, due to methodological limitations and poor applicability to U.S. EMS settings (SOE: insufficient). There was insufficient evidence from two observational studies to compare parenteral routes of administration (IM, IV, or subcutaneous [SQ]). No study compared outcomes of patients transported versus not transported following successful reversal of opioid overdose with naloxone. Five studies reported low rates of deaths and serious adverse events (0% to 1.25%) in patients not transported to a hospital after successful naloxone treatment, but used an uncontrolled design and had other methodological limitations (SOE: insufficient). Limitations. Few studies met inclusion criteria, all studies had methodological limitations, and no study evaluated naloxone auto-injectors or IN naloxone formulations recently approved by the US Food and Drug Administration (FDA). Conclusions. Low-strength evidence suggested that higher-concentration IN naloxone (2 mg/1 mL) is similar in efficacy to IM naloxone (2 mg), with no difference in adverse events. Research is needed on the comparative effectiveness of the FDA-approved naloxone auto-injectors (0.4 mg and 2 mg) and highly concentrated (4 mg/0.1 mL and 2 mg/0.1 mL) IN naloxone reformulation, different doses, and dosing strategies. Uncontrolled studies suggested that nontransport of patients following successful reversal of naloxone overdose might be associated with a low rate of serious harms, but patients were probably at low risk for such events, and there was insufficient evidence to determine risk of transport versus nontransport.'],
      ['Treatments for Adults with Schizophrenia: A Systematic Review [Entered Retrospectively]', 'Objectives. This systematic review (SR) provides evidence on pharmacological and psychosocial treatments for schizophrenia. Data sources. MEDLINE®, the Cochrane Library databases, PsycINFO® and included studies through February 22017. Study selection. We included studies comparing second generation antipsychotics (SGA) with each other or with a first generation antipsychotic (FGA) and studies comparing psychosocial interventions with usual care in adults with schizophrenia. Data extraction. We extracted study design, year, setting, country, sample size, eligibility criteria, population, clinical and intervention characteristics, results, and funding source. Results. We included one SR of 138 trials (N=47,189) and 24 trials (N=6,672) for SGAs versus SGAs, one SR of 111 trials (N=118,503) and five trials (N=1,055) for FGAs versus SGAs, and 13 SRs of 271 trials (N=25,050) and 27 trials (n=6,404) for psychosocial interventions. Trials were mostly fair quality and strength of evidence was low or moderate. For drug therapy, the majority of the head to head evidence was on older SGAs, with sparse data on SGAs approved in the last 10 years (asenapine, lurasidone, iloperidone, cariprazine, brexpiprazole), and recent long-acting injection [LAI] formulations of aripiprazole and paliperidone. Older SGAs were similar in measures of function, quality of life, mortality, and overall adverse events, except that risperidone LAI had better social function than quetiapine. Core illness symptoms were improved more with olanzapine and risperidone than asenapine, quetiapine, and ziprasidone and more with paliperidone than lurasidone and iloperidone; all were superior to placebo. Risperidone LAI and olanzapine had less withdrawal due to adverse events. Compared with olanzapine and risperidone, haloperidol, the most studied FGA, had similar improvement in core illness symptoms, negative symptoms, symptom response, and remission but greater incidence of adverse event outcomes. In comparison with usual care, most psychosocial interventions reviewed were more effective in improving intervention-targeted outcomes, including core illness symptoms. Various functional outcomes were improved more with assertive community care, cognitive behavioral therapy, family interventions, psychoeducation, social skills training, supported employment, and early interventions for first episode psychosis (FEP) than with usual care. Quality of life was improved more with cognitive behavioral therapy and early interventions for FEP than usual care. Relapse was reduced with family interventions, psychoeducation, illness self-management, family interventions, and early interventions for FEP. Conclusions. Most comparative evidence on pharmacotherapy relates to the older drugs, with clozapine, olanzapine, and risperidone superior on more outcomes than other SGAs. Older SGAs were similar to haloperidol on benefit outcomes but had fewer adverse event outcomes. Most psychosocial interventions improved functional outcomes, quality of life, and core illness symptoms, and several reduced relapse compared with usual care.'],
      ['Diagnostic Accuracy of Screening Tests and Treatment of Post-Acute Coronary Syndrome (ACS) Depression: A Systematic Review', ' Objective: To evaluate (1) the diagnostic accuracy of selected depression screening instruments and strategies versus a validated criterion standard in adult patients within 3 months of an acute coronary syndrome (ACS) event, and ((2) the comparative safety and effectiveness of a broad range of pharmacologic and nonpharmacologic treatments for depression in adult patients who have received a criterion-based diagnosis of depression or had clinically important depressive symptoms using a validated depression scale, and who are within 3 months of an ACS event. Data Sources: We searched PubMed®, Embase®, PsycINFO®, CINAHL®, and the Cochrane Database of Systematic Reviews for English-language studies published from January 1, 2003, to April 27, 2017, that evaluated the accuracy of tools for diagnosing depression in patients after ACS or that evaluated interventions for treating post-ACS patients identified with depression. Review Methods: Two investigators individually screened each abstract and full-text article for inclusion; abstracted data; and rated quality, applicability, and strength of evidence. Where appropriate, random-effects models were used to compute summary estimates of effects.'],
      ['The Role of Immunotherapy in the Treatment of Asthma', ' To evaluate the efficacy and safety of subcutaneous immunotherapy (SCIT) and sublingual immunotherapy (SLIT) in the treatment of allergic asthma'],
      ['Diet and PA for Prevention of Diabetes-Full Data Extraction', ''],
      ['Diagnosis and Treatment of Attention Deficit Hyperactivity Disorder (ADHD) in Children and Adolescents', 'Objectives. Attention deficit hyperactivity disorder (ADHD) is a common pediatric neurobehavioral disorder often treated in the primary care setting. This systematic review updates and extends two previous systematic evidence revieews and focuses on the comparative effectiveness of methods to establish the diagnosis of ADHD, updates the comparative effectiveness of pharmacologic and nonpharmacologic treatments, and evaluates different monitoring strategies in the primary care setting for individuals from birth through 17 years of age. Data sources. We searched PubMed®, Embase®, PsycINFO® and the Cochrane Database of Systematic Reviews for relevant English-language studies published from January 1, 2011, through November 7, 2016. Review methods. Two investigators screened each abstract and full-text article for inclusion, abstracted the data, and performed quality ratings and evidence grading. Random-effects models were used to compute summary estimates of effects when sufficient data were available for meta-analysis.'],
      ['Fractional Exhaled Nitric Oxide Clinical Utility in Asthma Management', 'To evaluate the clinical utility and diagnostic accuracy of fractional exhaled nitric oxide (FeNO) in people age 5 years and older with asthma; and the ability of FeNO measured at age 4 years or younger to predict a future diagnosiis of asthma.'],
      ['Anxiety in Children', 'To evaluate the comparative effectiveness and safety of treatments for childhood anxiety disorders, including panic disorder, social anxiety disorder, specific phobias, generalized anxiety disorder, and separation anxiety. PubMed IID: Data were entered into this project retrospectively using a PDF format files, including studies characteristics, binary outcomes, continuous outcomes, withdraw outcomes and studies quality.'],
      ['Interventions Targeting Sensory Challenges in Children with Autism Spectrum Disorder (ASD)—An Update', 'This review was conducted to evaluate the effectiveness and safety of interventions targeting sensory challenges in children with Autism Spectrum Disorder (ASD). This report is a update on a previous report from 2011.'],
      ['Medical Therapies for Children with Autism Spectrum Disorder—An Update', 'This review was conducted to evaluate the comparative effectiveness and safety of medical interventions (defined broadly as interventions involving the administration of external substances to the body or use of external, non-behavvioral procedures to treat symptoms of ASD) for children with Autism Spectrum Disorder (ASD). This report is a update on a previous report from 2011.'],
      ['VTE thromboprophylaxis with major orthopedic surgery', 'Update of review of VTE thromboprophylaxis after total hip replacement, total knee replacement, and hip fracture surgery.'],
      ['Treatment Strategies for Patients with Lower Extremity Chronic Venous Disease (LECVD)', 'Objectives. For patients with lower extremity chronic venous disease (LECVD), the optimal diagnostic testing and treatment for symptom relief, preservation of limb function, and improvement in quality of life is not known. This sysstematic review included a narrative review of diagnostic testing modalities and assessed the comparative effectiveness of exercise training, medical therapy, weight reduction, mechanical compression therapy, and invasive procedures (i.e., surgical and endovascular procedures) in patients with LECVD. Data sources. We searched PubMed®, Embase®, and the Cochrane Database of Systematic Reviews for relevant English-language studies published from January 1, 2000 to June 30, 2016. Review methods. Two investigators screened each abstract and full-text article for inclusion, abstracted the data, and performed quality ratings and evidence grading. Random-effects models were used to compute summary estimates of effects. Results. A total of 111 studies contributed evidence, as follows: Diagnosis of LECVD: A narrative review was conducted due to the scant literature and availability of only 10 observational studies evaluating the comparative effectiveness of diagnostic testing modalities in a heterogeneous population of patients with LECVD. In addition to the history and physical exam, multiple physiologic and imaging modalities (plethysmography, duplex ultrasound, intravascular ultrasonography, magnetic resonance venography, computed tomography venography, and invasive venography) are useful to confirm LECVD and/or localize the disease and guide therapy. There was insufficient evidence to support or refute the recommendations from current clinical guidelines that duplex ultrasound should be used as the firstline diagnostic test for patients being evaluated for LECVD or for those for whom invasive treatment is planned. Treatment of lower extremity chronic venous insufficiency/incompetence/reflux: Ninety-three studies (87 randomized controlled trials, 6 observational) evaluated the comparative effectiveness of exercise training, medical therapy, weight reduction, mechanical compression therapy, surgical intervention, and endovenous intervention in patients with lower extremity chronic venous insufficiency/incompetence/reflux. There was no long-term difference in effectiveness between radiofrequency ablation (RFA) and high ligation plus stripping, but RFA was associated with less periprocedural pain, faster improvement in symptom scores and quality of life, and fewer adverse events. Among patients undergoing endovenous interventions, RFA, endovenous laser ablation (EVLA), and sclerotherapy demonstrated improvement in quality-of-life scores and standardized symptom scores. When compared with patients treated with EVLA, those treated with foam sclerotherapy had significantly less periprocedural pain but lower rates of vein occlusion and higher rates of repeat intervention, and patients treated with RFA had significantly less periprocedural pain but also less short-term improvement in Venous Clinical Severity Score. When compared with patients treated with placebo, those treated with foam sclerotherapy had statistically significant improvement in standardized symptom scores, occlusion rates, and quality of life. When compared with patients treated with placebo or no compression therapy, those treated with compression therapy had significant improvement in standardized symptom scores and quality of life. Treatment of lower extremity chronic venous obstruction/thrombosis: Eight studies (3 randomized controlled trials, 5 observational) evaluated the comparative effectiveness of exercise training, medical therapy, weight reduction, mechanical compression therapy, surgical intervention, and endovenous intervention in patients with lower extremity chronic venous obstruction/thrombosis. In patients with post-thrombotic syndrome, exercise training plus patient education and monthly phone follow-up resulted in improved quality of life but not improved symptom severity when compared with patient education and monthly phone follow-up. In patients with both May-Thurner Syndrome and superficial venous reflux who were treated with EVLA (with or without stent placement), there were fewer recurrent ulcerations, improvement in reflux severity and symptoms, and improvement in quality of life in long-term follow-up. In patients with chronic proximal iliac vein obstruction, treatment with catheter-directed urokinase at the time of endovenous stenting resulted in similar effectiveness but catheter-directed urokinase had higher technical failure rates and bleeding risk when compared with endovenous stenting alone. Very few studies evaluated modifiers of effectiveness in the study population. Conclusions. The available evidence for treatment of patients with LECVD is limited by heterogeneous studies that compared multiple treatment options, measured varied outcomes, and assessed disparate outcome timepoints. Very limited comparative effectiveness data have been generated to study new and existing diagnostic testing modalities for patients with LECVD. When compared with patients’ baseline measures, endovenous interventions (e.g. EVLA, sclerotherapy, and RFA) and surgical ligation demonstrated improvement in quality-of-life scores and Venous Clinical Severity Score at various timepoints after treatment; however, there were no statistically significant differences in outcomes between treatment groups (e.g. endovenous vs. endovenous; endovenous vs. surgical). Several advances in care in endovenous interventional therapy have not yet been rigorously tested, and there are very few studies on conservative measures (e.g., lifestyle modification, compression therapy, exercise training) in the literature published since 2000. Additionally, the potential additive effects of many of these therapies are unknown. The presence of significant clinical heterogeneity of these results makes conclusions for clinical outcomes uncertain and provides an impetus for further research to improve the care of patients with LECVD.'],
      ['Systematic Review on the Use of Cryotherapy Versus other Treatments for Basal Cell Carcinoma', 'Our objective is to determine the efficacy and adverse events profile of cryotherapy for the treatment of basal cell carcinoma compared to other therapeutic options or non intervention.'],
      ['Glasgow Coma Scale for Field Triage of Trauma: A Systematic Review [Entered Retrospectively]', 'Objectives. To assess the predictive utility, reliability, and ease of use of the total Glasgow Coma Scale (tGCS) versus the motor component of the Glasgow Coma Scale (mGCS) for field triage of trauma, as well as comparative effectts on clinical decisionmaking and clinical outcomes. Data Sources. MEDLINE®, CINAHL, PsycINFO, HAPI (Health & Psychosocial Instruments), and the Cochrane Databases (January 1995 through June, 2016). Additional studies were identified from reference lists and technical experts. Study Selection. Studies on the predictive utility of the tGCS versus the mGCS or Simplified Motor Scale (SMS) (a simplified version of the mGCS), randomized trials and cohort studies on effects of the tGCS versus the mGCS on rates of over- or under-triage, and studies on interrater reliability and ease of use of the tGCS, mGCS, and/or SMS. Data Extraction. One investigator abstracted details about study characteristics and results; a second investigator checked data for accuracy. Two investigators independently applied prespecified criteria to rate study quality. Data on discrimination of tGCS versus mGCS and tGCS versus SMS were pooled using a random effects model. The strength of evidence was determined based on the overall risk of bias, consistency, directness, precision, and reporting bias. Results. 33 studies met inclusion criteria; 24 studies addressed predictive utility and 10 addressed interrater reliability or ease of use. No study assessed comparative effects on over- or under-triage or clinical outcomes. For in-hospital mortality, the tGCS is associated with slightly greater discrimination than the mGCS (pooled mean difference in area under the receiver operating characteristic curve [AUROC] 0.015, 95% confidence interval [CI] 0.009 to 0.022, I2=85%, 12 studies; strength of evidence [SOE]: Moderate) or the SMS (pooled mean difference in AUROC 0.030, 95% CI 0.024 to 0.036, I2=0%, 5 studies; SOE: Moderate). This means that for every 100 trauma patients, the tGCS is able to correctly discriminate 1 to 3 more cases of in-hospital mortality from cases without in-hospital mortality than the mGCS or the SMS . The tGCS is also associated with greater discrimination than the mGCS or SMS for receipt of neurosurgical interventions, severe brain injury, and emergency intubation (differences in AUROC ranged from 0.03 to 0.05; SOE: Moderate). Differences in discrimination between the mGCS versus the SMS were small (differences in the AUROC ranged from 0.000 to 0.01; SOE: Moderate). Findings were robust in sensitivity and subgroup analyses based on age, type of trauma, study years, assessment setting (out-of-hospital vs. emergency department), risk of bias assessment, and other factors. Differences between the tGCS, mGCS, and SMS in diagnostic accuracy (sensitivity, specificity) based on standard thresholds (scores of ≤15, ≤5, and ≤1) were small, based on limited evidence (SOE: Low). The interrater reliability of tGCS and mGCS appears to be high, but evidence was insufficient to determine if there were differences between scales (SOE: Insufficient). Three studies found the tGCS associated with a lower proportion of correct scores than the mGCS (differences in proportion of correct scores ranged from 6% to 27%), though the difference was statistically significant in only one study (SOE: Low). Limitations. Evidence on comparative predictive utility was primarily restricted to effects on discrimination. All studies on predictive utility were retrospective and the mGCS and SMS were taken from the tGCS rather than independently assessed. Most studies had methodological limitations. We restricted inclusion to English-language studies and were limited in our ability to assess publication bias. Studies on ease of use focused on scoring of video or written patient scenarios; field studies and studies on other measures of ease of use such as time required and assessor satisfaction were not available. Conclusions. The tGCS is associated with slightly greater discrimination than the mGCS or SMS for in-hospital mortality, receipt of neurosurgical interventions, severe brain injury, and emergency intubation. The clinical significance of small differences in discrimination is likely to be small, and could be offset by factors such as convenience and ease of use. Research is needed to understand how use of the tGCS versus the mGCS or SMS impacts clinical outcomes and risk of over- or under-triage.'],
      ['Systematic review of the adverse reproductive and developmental effects of caffeine consumption in healthy adults and pregnant women', ' To date, one of the most heavily cited assessments of caffeine safety in the peer-reviewed literature is that issued by Health Canada (Nawrot et al., 2003). Since then, >10,000 papers have been published related to caffeine, inccluding hundreds of reviews on specific human health effects; however, to date, none have compared the wide range of topics evaluated by Nawrot et al. (2003). Thus, as an update to this foundational publication, we conducted a systematic review of data on potential adverse effects of caffeine published from 2001 to June 2015. Subject matter experts and research team participants developed five PECO (population, exposure, comparator, and outcome) questions to address five types of outcomes (acute toxicity, cardiovascular toxicity, bone and calcium effects, behavior, and development and reproduction) in four healthy populations (adults, pregnant women, adolescents, and children) relative to caffeine intake doses determined not to be associated with adverse effects by Health Canada (comparators: 400 mg/day for adults [10 g for lethality], 300 mg/day for pregnant women, and 2.5 mg/kg/day for children and adolescents). The a priori search strategy identified >5000 articles that were screened, with 381 meeting inclusion/exclusion criteria for the five outcomes (pharmacokinetics was addressed contextually, adding 46 more studies). Data were extracted by the research team and rated for risk of bias and indirectness (internal and external validity). Selected no- and low-effect intakes were assessed relative to the population-specific comparator. Conclusions were drawn for the body of evidence for each outcome, as well as endpoints within an outcome, using a weight of evidence approach. When the total body of evidence was evaluated and when study quality, consistency, level of adversity, and magnitude of response were considered, the evidence generally supports that consumption of up to 400 mg caffeine/day in healthy adults is not associated with overt, adverse cardiovascular effects, behavioral effects, reproductive and developmental effects, acute effects, or bone status. Evidence also supports consumption of up to 300 mg caffeine/day in healthy pregnant women as an intake that is generally not associated with adverse reproductive and developmental effects. Limited data were identified for child and adolescent populations; the available evidence suggests that 2.5 mg caffeine/kg body weight/day remains an appropriate recommendation. The results of this systematic review support a shift in caffeine research to focus on characterizing effects in sensitive populations and establishing better quantitative characterization of interindividual variability (e.g., epigenetic trends), subpopulations (e.g., unhealthy populations, individuals with preexisting conditions), conditions (e.g., coexposures), and outcomes (e.g., exacerbation of risk-taking behavior) that could render individuals to be at greater risk relative to healthy adults and healthy pregnant women. This review, being one of the first to apply systematic review methodologies to toxicological assessments, also highlights the need for refined guidance and frameworks unique to the conduct of systematic review in this field.'],
      ['Systematic review of the adverse behavioral effects of caffeine consumption in healthy adults, pregnant women, adolescents, and children', 'To date, one of the most heavily cited assessments of caffeine safety in the peer-reviewed literature is that issued by Health Canada (Nawrot et al., 2003). Since then, >10,000 papers have been published related to caffeine, inccluding hundreds of reviews on specific human health effects; however, to date, none have compared the wide range of topics evaluated by Nawrot et al. (2003). Thus, as an update to this foundational publication, we conducted a systematic review of data on potential adverse effects of caffeine published from 2001 to June 2015. Subject matter experts and research team participants developed five PECO (population, exposure, comparator, and outcome) questions to address five types of outcomes (acute toxicity, cardiovascular toxicity, bone and calcium effects, behavior, and development and reproduction) in four healthy populations (adults, pregnant women, adolescents, and children) relative to caffeine intake doses determined not to be associated with adverse effects by Health Canada (comparators: 400 mg/day for adults [10 g for lethality], 300 mg/day for pregnant women, and 2.5 mg/kg/day for children and adolescents). The a priori search strategy identified >5000 articles that were screened, with 381 meeting inclusion/exclusion criteria for the five outcomes (pharmacokinetics was addressed contextually, adding 46 more studies). Data were extracted by the research team and rated for risk of bias and indirectness (internal and external validity). Selected no- and low-effect intakes were assessed relative to the population-specific comparator. Conclusions were drawn for the body of evidence for each outcome, as well as endpoints within an outcome, using a weight of evidence approach. When the total body of evidence was evaluated and when study quality, consistency, level of adversity, and magnitude of response were considered, the evidence generally supports that consumption of up to 400 mg caffeine/day in healthy adults is not associated with overt, adverse cardiovascular effects, behavioral effects, reproductive and developmental effects, acute effects, or bone status. Evidence also supports consumption of up to 300 mg caffeine/day in healthy pregnant women as an intake that is generally not associated with adverse reproductive and developmental effects. Limited data were identified for child and adolescent populations; the available evidence suggests that 2.5 mg caffeine/kg body weight/day remains an appropriate recommendation. The results of this systematic review support a shift in caffeine research to focus on characterizing effects in sensitive populations and establishing better quantitative characterization of interindividual variability (e.g., epigenetic trends), subpopulations (e.g., unhealthy populations, individuals with preexisting conditions), conditions (e.g., coexposures), and outcomes (e.g., exacerbation of risk-taking behavior) that could render individuals to be at greater risk relative to healthy adults and healthy pregnant women. This review, being one of the first to apply systematic review methodologies to toxicological assessments, also highlights the need for refined guidance and frameworks unique to the conduct of systematic review in this field.'],
    ]

    object.instance_exec do
      # Turn off paper_trail.
      PaperTrail.enabled = false

      # Seed Extraction Forms.
      @ef1 = ExtractionForm.create(name: 'ef1')

      # Seed Key Questions.
      @kq1 = KeyQuestion.create(name: 'kq1')
      @kq2 = KeyQuestion.create(name: 'kq2')

      # Users.
      @superadmin = User.create do |u|
        u.email        = 'superadmin@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @contributor = User.create do |u|
        u.email        = 'jensjap@gmail.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @auditor = User.create do |u|
        u.email        = 'auditor@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @tester = User.create do |u|
        u.email        = 'tester@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @organizations = Organization.create([
        { name: 'Brown University' },
        { name: 'Johns Hopkins University' }
      ])

      # Organizations.
      @cochrane          = Organization.create(name: 'Cochrane')
      @red_hair_pirates  = Organization.create(name: 'Red Hair Pirates')
      @straw_hat_pirates = Organization.create(name: 'Straw Hat Pirates')
      @roger_pirates     = Organization.create(name: 'Roger Pirates')

      # For assignments.
      @screener_1 = User.create do |u|
        u.email        = 'screener_1@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @screener_2 = User.create do |u|
        u.email        = 'screener_2@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @screener_3 = User.create do |u|
        u.email        = 'screener_3@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @screeners = [@screener_1, @screener_2, @screener_3]

      # Add data to sample profiles.
      # Profiles are created in after_create callback in user model.
      @superadmin.profile.update(
        organization: @red_hair_pirates,
        username:    'superadmin',
        first_name:  'Red',
        middle_name: 'Haired',
        last_name:   'Shanks')
      @contributor.profile.update(
        organization: @straw_hat_pirates,
        username:    'contributor',
        first_name:  'Nico',
        middle_name: '',
        last_name:   'Robin')
      @auditor.profile.update(
        organization: @straw_hat_pirates,
        username:    'auditor',
        first_name:  'Roronoa',
        middle_name: '',
        last_name:   'Zoro')
      @tester.profile.update(
        organization: @roger_pirates,
        username:    'tester',
        first_name:  'Gol',
        middle_name: 'D',
        last_name:   'Roger')
      @screener_1.profile.update(
        organization: @roger_pirates,
        username:    'screener_1',
        first_name:  'Arthur',
        middle_name: 'C',
        last_name:   'Clarke')
      @screener_2.profile.update(
        organization: @roger_pirates,
        username:    'screener_2',
        first_name:  'Isaac',
        middle_name: '',
        last_name:   'Asimov')
      @screener_3.profile.update(
        organization: @roger_pirates,
        username:    'screener_3',
        first_name:  'Douglas',
        middle_name: 'Noel',
        last_name:   'Adams')


      # Degrees.
      @bachelor_arts    = Degree.create(name: 'Bachelor of Arts - BA')
      @bachelor_science = Degree.create(name: 'Bachelor of Science - BS')
      @master_arts      = Degree.create(name: 'Master of Arts - MA')
      @master_science   = Degree.create(name: 'Master of Science - MS')
      @msph             = Degree.create(name: 'Master of Science in Public Health - MSPH')
      @jd               = Degree.create(name: 'Juris Doctor - JD')
      @md               = Degree.create(name: 'Medical Doctor - MD')
      @phd              = Degree.create(name: 'Doctor of Philosophy - PhD')

      # Suggestions.
      @cochrane.create_suggestion(user: @contributor)
      @red_hair_pirates.create_suggestion(user: @superadmin)
      @roger_pirates.create_suggestion(user: @superadmin)
      @msph.create_suggestion(user: @auditor)
      @jd.create_suggestion(user: @contributor)

      # Degrees-Profiles Associations.
      @bachelor_arts.profiles << @superadmin.profile
      @bachelor_arts.profiles << @contributor.profile
      @bachelor_science.profiles << @auditor.profile
      @master_arts.profiles << @superadmin.profile
      @master_science.profiles << @auditor.profile
      @msph.profiles << @superadmin.profile
      @msph.profiles << @contributor.profile
      @jd.profiles << @auditor.profile
      @msph.profiles << @auditor.profile

      # Projects.
      project_titles.each do |n|
        updated_at = Faker::Time.between(DateTime.now - 1000, DateTime.now - 1)
        Project.create!(name:        n[0],
                        description: n[1],
                        attribution: Faker::Cat.registry,
                        methodology_description: Faker::HarryPotter.quote,
                        prospero:                Faker::Number.hexadecimal(12),
                        doi:                     Faker::Number.hexadecimal(6),
                        notes:                   Faker::HarryPotter.book,
                        funding_source:          Faker::Book.publisher,
                        created_at:              updated_at - rand(1000).hours,
                        updated_at:              updated_at)
        Faker::UniqueGenerator.clear
      end

      # Associate KQ's and EF's with first project.
      @project = Project.order(updated_at: :desc).first
      @project.key_questions << [@kq1, @kq2]

      @primary        = CitationType.create(name: 'Primary')
      @secondary      = CitationType.create(name: 'Secondary')
      @abstrackr      = CitationType.create(name: 'Abstrackr')
      @citation_types = [@primary, @secondary]

      # Citations, Journals, Authors and Keywords
      1000.times do |n|
        updated_at = Faker::Time.between(DateTime.now - 1000, DateTime.now - 1)
        c = Citation.create(
          name:           Faker::Lorem.sentence,
          pmid:           Faker::Number.number(10),
          refman:         Faker::Number.number(9),
          abstract:       Faker::Lorem.paragraph,
          citation_type:  @citation_types.sample,
          created_at:     updated_at - rand(1000).hours,
          updated_at:     updated_at
        )


        # Journals
        Journal.create(
          name:              Faker::RockBand.name,
          publication_date:  Faker::Date.backward(10000),
          volume:            Faker::Number.number(1),
          issue:             Faker::Number.number(1),
          citation:          c
        )

        # Keywords
        5.times do |n|
          c.keywords << Keyword.create(name:     Faker::Hipster.word)
        end

        # Authors
        5.times do |n|
          c.authors << Author.create(name:     Faker::HitchhikersGuideToTheGalaxy.character)
        end

      end

      # Combine a bunch of activities we do for each project:
      #
      # - Publishing requests
      # - Publishing approvals
      # - Project memberships
      # - Set of citations
      # - Set of screening tasks
      @perpetual      = TaskType.find_by(name: 'Perpetual')
      @pilot          = TaskType.find_by(name: 'Pilot')
      @advanced       = TaskType.find_by(name: 'Advanced')

      Project.all.each do |p|

        # Randomly assign publishing requests and approvals.
        requested_by = User.offset(rand(User.count)).first
        approved_by = User.offset(rand(User.count)).first

        case rand(10)
        when 0  # Create Publishing object.
          p.request_publishing_by(User.first)
          p.request_publishing_by(User.second)
        when 1  # Create Publishing object.
          p.request_publishing_by(User.first)
          p.request_publishing_by(User.third)
        when 2  # Create Publishing object and approve it.
          Publishing.create(publishable: p, user: requested_by)
            .approve_by(approved_by)
        end

        # Make contributor a project member.
        p.users << @superadmin
        p.users << @contributor
        p.users << @screener_1
        p.users << @screener_2
        p.users << @screener_3

        # Seed ProjectsUsersRole.
        ProjectsUser.find_by(project: p, user: @superadmin).roles  << Role.where(name: 'Contributor')
        ProjectsUser.find_by(project: p, user: @contributor).roles << Role.where(name: 'Leader')
        ProjectsUser.find_by(project: p, user: @contributor).roles << Role.where(name: 'Contributor')
        ProjectsUser.find_by(project: p, user: @screener_1).roles << Role.where(name: 'Contributor')
        ProjectsUser.find_by(project: p, user: @screener_2).roles << Role.where(name: 'Contributor')
        ProjectsUser.find_by(project: p, user: @screener_3).roles << Role.where(name: 'Contributor')

        # Assign a random sample of 50 citations to project.
        p.citations = Citation.all.sample(50)

        case rand(3)
        when 0
          Task.create(
            num_assigned: 100,
            task_type:    @perpetual,
            project:      p
          )
        when 1
          pilot_size = rand(100)
          Task.create(
            num_assigned: pilot_size,
            task_type:    @pilot,
            project:      p
          )
          Task.create(
            num_assigned: 100 - pilot_size,
            task_type:    @perpetual,
            project:      p
          )

        when 2
          advanced_size = rand(100)
          Task.create(
            num_assigned: advanced_size,
            task_type:    @advanced,
            project:      p
          )
          Task.create(
            num_assigned: 100 - advanced_size,
            task_type:    @advanced,
            project:      p
          )
        end
      end

      # Assignments.
      Task.all.each do |t|
        case t.task_type.name
        when 'Perpetual', 'Pilot'
          Assignment.create([
            {
              date_assigned: DateTime.now,
              date_due: Date.today + 7,
              projects_users_role: ProjectsUsersRole.find_by({ projects_user: ProjectsUser.find_by({ user: @screener_1, project: p }), role: Role.where(name: 'Contributor') }),
              task: t
            },
            {
              date_assigned: DateTime.now,
              date_due: Date.today + 7,
              projects_users_role: ProjectsUsersRole.find_by({ projects_user: ProjectsUser.find_by({ user: @screener_2, project: p }), role: Role.where(name: 'Contributor') }),
              task: t
            },
            {
              date_assigned: DateTime.now,
              date_due: Date.today + 7,
              projects_users_role: ProjectsUsersRole.find_by({ projects_user: ProjectsUser.find_by({ user: @screener_3, project: p }), role: Role.where(name: 'Contributor') }),
              task: t
            }
          ])
        when 'Advanced'
          for s in @screeners.sample(rand(3))
            Assignment.create(
              date_assigned: DateTime.now,
              date_due: Date.today + 7,
              projects_users_role: ProjectsUsersRole.find_by({ projects_user: ProjectsUser.find_by({ user: s, project: p }), role: Role.where(name: 'Contributor') }),
              task: t
            )
          end
        end
      end

      # Messages.
      @totd = MessageType.first
      100.times do
        @totd.messages.create(name: Faker::HarryPotter.unique.book,
                              description: Faker::ChuckNorris.unique.fact,
                              start_at: 10.minute.ago)
        Faker::UniqueGenerator.clear
      end

      # Turn on paper_trail.
      PaperTrail.enabled = true
    end
  end
end
