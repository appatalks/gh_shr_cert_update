# gh_shr_cert_update
Getting around "Disabling TLS certificate verification" for GitHub Self-Hosted Runners

There is probablly a better way to impliment this, and that's what this aim's to do.

> [Disabling TLS certificate verification](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/monitoring-and-troubleshooting-self-hosted-runners#disabling-tls-certificate-verification)

> By default, the self-hosted runner application verifies the TLS certificate for GitHub. If you encounter network problems, you may wish to disable TLS certificate verification for testing purposes.

> To disable TLS certification verification in the self-hosted runner application, set the GITHUB_ACTIONS_RUNNER_TLS_NO_VERIFY environment variable to 1 before configuring and running the self-hosted runner application.

> ```bash
> export GITHUB_ACTIONS_RUNNER_TLS_NO_VERIFY=1
> ./config.sh --url https://github.com/YOUR-ORG/YOUR-REPO --token
> ./run.sh
> ```

> [!WARNING]
> Warning: Disabling TLS verification is not recommended since TLS provides privacy and data integrity between the self-hosted runner application and GitHub. We recommend that you install the GitHub certificate in the operating system certificate store for your self-hosted runner. For guidance on how to install the GitHub certificate, check with your operating system vendor.
