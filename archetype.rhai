let context = #{};

// Pass `-s debug-answers` to archetect to output the answers it sees from various sources
if switch_enabled("debug-answers") {
    print("Answers:");
    print(as_yaml(ANSWERS));
    print();
}

context += render(Archetype("org-prompts"), ANSWERS);

if ANSWERS.menus != () {
    for menu in ANSWERS.menus {  // get an array of all the property names via 'keys'
        if menu["select_type"] == "single" {
            context += prompt(menu["menu_name"] + ":", menu["menu_name"], #{
                    help: "Project Features",
                    type: Select(menu["menu_options"] + ["None"]),
                });
        } else {
            context += prompt(menu["menu_name"] + ":", menu["menu_name"], #{
                help: "Project Features",
                type: MultiSelect(menu["menu_options"]),
            });
        }
    }
}

context += prompt("Project Prefix:", "project-prefix", #{
    cases: [
        CasedIdentityCasedValue(PROGRAMMING_CASES),
    ],
});

context+= prompt("Project Suffix:", "project-suffix", #{
    type: Select([
        "RayService",
        "RayCluster",
        "RayJob",
    ]),
    cases: [
        CasedIdentityCasedValue(PROGRAMMING_CASES),
    ],
});


context += set("project-name", render("{{ project-prefix }}-{{ project-suffix }}", context), #{
    cases: [
        CasedIdentityCasedValue(PROGRAMMING_CASES),
        FixedKeyCasedValue("project-title", TitleCase),
    ],
});

context += prompt("Project Author:", "author_full", #{
    placeholder: "Your Name <your.name@example.com>",
});


context += prompt("Features:", "features", #{
    type: MultiSelect([
      "RayData",
      "RayTrain",
      "RayTune",
      "RayServe",
      "RayRLib"
    ]),
});

context += prompt("Application:", "application", #{
    type: MultiSelect([
      "router",
      "inferencer",
      "rayfast",
      "hello"
    ]),
    cases: [
        CasedKeyCasedValue("application-name", PROGRAMMING_CASES),
    ],
});

context += prompt("RayClusterHeadService:", "ray-head-name", #{
        cases: [
        CasedIdentityCasedValue(PROGRAMMING_CASES),
    ],
});

// Pass `-s debug-context` to archetect to output the context 
if switch_enabled("debug-context") {
    print("Context:");
    print(as_yaml(context));
    print();
}

context["github-artifactory_username"] = "${{ secrets.ARTIFACTORY_USERNAME }}";
context["github-artifactory_id_token"] = "${{ secrets.ARTIFACTORY_IDENTITY_TOKEN }}";

render(Directory("contents/base"), context);


context

