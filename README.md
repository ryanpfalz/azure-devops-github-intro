# azure-devops-intro

---

| Page Type | Languages | Services                            |
| --------- | --------- | ----------------------------------- |
| Sample    | C#        | Azure DevOps <br> Azure App Service |

---

# Setting up Azure DevOps

This document seeks to cover key features in Azure DevOps by providing relevant resources so that a basic end-to-end DevOps process can be built. This document aims to serve as a collection of useful documents/links, and **does not intend to be an exhaustive or step-by-step guide**.
<br>
The sample code in this repository contains a basic build configuration, infrastructure-as-code, and .NET application code that can be imported into Azure DevOps to help accelerate/provide a reference point for new projects.

<img src="./docs/devopscycle.png" alt="DevOps cycle" width="500"/><br>

_Detailed phases of the DevOps cycle._

---

| DevOps Phase/Area | Azure DevOps tool                                                                                                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Planning          | [Boards](https://azure.microsoft.com/en-us/products/devops/boards/)                                                                                                                                                       |
| Collaboration     | [Repos](https://azure.microsoft.com/en-us/products/devops/repos/)                                                                                                                                                         |
| Development       | [Dev Box](https://azure.microsoft.com/en-us/products/dev-box/#overview) (cloud)<br>[Visual Studio](https://visualstudio.microsoft.com/)/[Visual Studio Code](https://code.visualstudio.com/) (local)                      |
| Delivery          | [Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops), [Test Plans](https://learn.microsoft.com/en-us/azure/devops/test/overview?view=azure-devops) |
| Operate           | [Dashboards](https://learn.microsoft.com/en-us/azure/devops/report/dashboards/overview?view=azure-devops)                                                                                                                 |

## Before you can use the tools in Azure DevOps...

-   [Create a DevOps Organization](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops)
-   [Create a project](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=browser)

## Planning tools

-   [How to get started with Azure Boards](https://learn.microsoft.com/en-us/azure/devops/boards/get-started/?view=azure-devops)
-   [Best practices for Agile project management](https://learn.microsoft.com/en-us/azure/devops/boards/best-practices-agile-project-management?view=azure-devops&tabs=agile-process)
-   [Backlogs, Boards, Taskboards, and Plans](https://learn.microsoft.com/en-us/azure/devops/boards/backlogs/backlogs-boards-plans?view=azure-devops)
-   [Team Retrospectives: DevOps Extension](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.team-retrospectives)

## Collaboration tools

-   [Code with Git](https://learn.microsoft.com/en-us/azure/devops/user-guide/code-with-git?view=azure-devops)
-   [Branch policies and settings](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops&tabs=browser)
-   [Adopt a Git branching strategy](https://learn.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance?view=azure-devops)

## Development tools

-   [Tools and clients that connect to Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/user-guide/tools?view=azure-devops)
-   [What is infrastructure as code (IaC)?](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)
-   [Getting started with Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin)
-   [IDE Language Analyzer for Security: VS Extension](https://marketplace.visualstudio.com/items?itemName=MS-CST-E.MicrosoftDevSkim)

## Delivery tools

-   [Create pull requests](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops&tabs=browser)
-   [Pull request build policies for high quality code](https://devblogs.microsoft.com/devops/pull-request-build-policies-for-high-quality-code/)
-   [Shift testing left with unit tests](https://learn.microsoft.com/en-us/devops/develop/shift-left-make-testing-fast-reliable)
-   [Deep dive into Azure Test Plans](https://azure.microsoft.com/en-us/blog/deep-dive-into-azure-test-plans/)
-   [End-to-end traceability](https://learn.microsoft.com/en-us/azure/devops/cross-service/end-to-end-traceability?toc=%2Fazure%2Fdevops%2Fboards%2Ftoc.json&view=azure-devops)
-   [Create your first build pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline?view=azure-devops&tabs=java%2Ctfs-2018-2%2Cbrowser)
-   [Release pipelines overview](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/?view=azure-devops)

## Operations tools

-   [Security best practices](https://learn.microsoft.com/en-us/azure/devops/organizations/security/security-best-practices?view=azure-devops)
-   [Wiki files and file structure](https://learn.microsoft.com/en-us/azure/devops/project/wiki/wiki-file-structure?view=azure-devops)
-   [Add charts to a dashboard](https://learn.microsoft.com/en-us/azure/devops/report/dashboards/add-charts-to-dashboard?view=azure-devops)
