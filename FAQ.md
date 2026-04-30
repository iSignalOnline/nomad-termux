# Frequently Asked Questions (FAQ) — Native Termux Fork

Find answers to some of the most common questions about Project N.O.M.A.D. (Native Termux Fork).

> This is the **de-containerized** Termux fork of Project N.O.M.A.D. — all services run natively inside Termux. Docker is not required. For the original Docker-based upstream project, see [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad).

## Does this fork require root or a custom kernel?

No. This fork is specifically designed to run without root access, without custom kernels, and without any Docker containers. Everything runs as native background processes inside Termux.

## Can I customize the port(s) that NOMAD uses?

Yes. Edit `~/.nomad_env` and change the `PORT` variable, then restart:

```bash
# In ~/.nomad_env
export PORT=9090

# Then restart
bash ~/nomad-termux/install/stop_termux.sh
bash ~/nomad-termux/install/start_termux.sh
```

## Can I customize the storage location for NOMAD's data?

Yes. Edit the `NOMAD_STORAGE_PATH` variable in `~/.nomad_env` before running `setup_termux.sh`, or after setup by stopping all services, moving the data directory, updating the variable, and restarting.

The default path is `~/nomad/data` (`/data/data/com.termux/files/home/nomad/data`).

## Can I store NOMAD's data on external storage?

Android's external storage (SD card / USB OTG) can be mounted and referenced via `NOMAD_STORAGE_PATH` in `~/.nomad_env`, but this depends on your device's storage permissions and Android version. On Android 11+, scoped storage restrictions may limit write access to external volumes. Internal Termux home storage is the most reliable option.

## What platform does this fork run on?

This fork runs on **Android** via [Termux](https://termux.dev/). It has been tested on arm64-v8a (64-bit ARM) devices, which covers the vast majority of modern Android phones.

## What are the hardware requirements?

See the [Device Requirements](README.md#device-requirements) section of the README. At minimum: Android 7.0+, 2 GB RAM, 2 GB free storage. For AI features, 6 GB+ RAM and 16 GB+ storage is recommended.

## What technologies is this fork built with?

| Component | Technology |
|---|---|
| Backend | Node.js / TypeScript ([AdonisJS](https://adonisjs.com/)) |
| Frontend | React + [Vite](https://vitejs.dev/) + [Inertia.js](https://inertiajs.com/) |
| Database | SQLite (file-based, installed automatically — no daemon required) |
| Cache / Queues | Redis (installed via `pkg install redis`) |
| Runtime | Native Termux processes (no Docker) |

This fork does **not** use Docker or the Docker-outside-of-Docker (DooD) pattern. All services run directly as native Termux background processes.

## Does this fork require Docker?

No. The entire purpose of this fork is to remove the Docker dependency. All services that previously ran in Docker containers now run natively in Termux.

## Can I use any AI models?

NOMAD supports any Ollama-compatible or OpenAI API-compatible backend. On Android, the practical option is a llama.cpp-based backend running on CPU since GPU acceleration is generally unavailable through Termux. You can:

- Point the AI Assistant to an Ollama instance running on another machine on your local network.
- Use a compatible API server (LM Studio, llama.cpp with server mode) on another host.
- Download and run models locally via Ollama if your device has sufficient RAM (7B+ models require 6–8 GB RAM).

To download a model via the API:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"model":"MODEL_NAME_HERE"}' \
  http://127.0.0.1:8080/api/ollama/models
```

## Do I have to install the AI features?

No. The AI features (Ollama, Qdrant, RAG pipeline) are optional and not required to use the core functionality of N.O.M.A.D.

## Does NOMAD support languages other than English?

The UI is currently English-only. Multi-language support is on the upstream project's roadmap.

## How do I view logs?

Since `docker logs` is no longer applicable, all logs are plain text files:

```bash
# Live Command Center log
tail -f ~/nomad/data/logs/nomad.log

# All logs
tail -n 100 ~/nomad/data/logs/nomad.log \
             ~/nomad/data/logs/nomad_err.log \
             ~/nomad/data/logs/redis.log
```

## Is NOMAD actually free? Are there any hidden costs?
Yes, Project N.O.M.A.D. is completely free and open-source software licensed under the Apache License 2.0. There are no hidden costs or fees associated with using NOMAD itself, and we don't have any plans to introduce "premium" features or paid tiers.

Aside from the cost of the hardware you choose to run it on, there are no costs associated with using NOMAD.

## Do you sell hardware or pre-built devices with NOMAD pre-installed?

No, we do not sell hardware or pre-built devices with NOMAD pre-installed at this time. Project N.O.M.A.D. is a free and open-source software project, and we provide detailed installation instructions and hardware recommendations for users to set up their own NOMAD instances on compatible hardware of their choice. The tradeoff to this DIY approach is some additional setup time and technical know-how required on the user's end, but it also allows for greater flexibility and customization in terms of hardware selection and configuration to best suit each user's unique needs, budget, and preferences.

## How quickly are issues resolved when reported?

We strive to address and resolve issues as quickly as possible, but please keep in mind that Project N.O.M.A.D. is a free and open-source project maintained by a small team of volunteers. We prioritize issues based on their severity, impact on users, and the resources required to resolve them. Critical issues that affect a large number of users are typically addressed more quickly, while less severe issues may take longer to resolve. Aside from the development efforts needed to address the issue, we do our best to conduct thorough testing and validation to ensure that any fix we implement doesn't introduce new issues or regressions, which also adds to the time it takes to resolve an issue.

We also encourage community involvement in troubleshooting and resolving issues, so if you encounter a problem, please consider checking our Discord community and Github Discussions for potential solutions or workarounds while we work on an official fix.

## How often are new features added or updates released?

We aim to release updates and new features on a regular basis, but the exact timing can vary based on the complexity of the features being developed, the resources available to our volunteer development team, and the feedback and needs of our community. We typically release smaller "patch" versions more frequently to address bugs and make minor improvements, while larger feature releases may take more time to develop and test before they're ready for release.

## I opened a PR to contribute a new feature or fix a bug. How long does it usually take for PRs to be reviewed and merged?
We appreciate all contributions to the project and strive to review and merge pull requests (PRs) as quickly as possible. The time it takes for a PR to be reviewed and merged can vary based on several factors, including the complexity of the changes, the current workload of our maintainers, and the need for any additional testing or revisions.

Because NOMAD is still a young project, some PRs (particularly those for new features) may take longer to review and merge as we prioritize building out the core functionality and ensuring stability before adding new features. However, we do our best to provide timely feedback on all PRs and keep contributors informed about the status of their contributions.

## I have a question that isn't answered here. Where can I ask for help?

If you have a question that isn't answered in this FAQ, please feel free to ask for help in our Discord community (https://discord.com/invite/crosstalksolutions) or on our Github Discussions page (https://github.com/Crosstalk-Solutions/project-nomad/discussions).

## I have a suggestion for a new feature or improvement. How can I share it?

We welcome and encourage suggestions for new features and improvements! We highly encourage sharing your ideas (or upvoting existing suggestions) on our public roadmap at https://roadmap.projectnomad.us, where we track new feature requests. This is the best way to ensure that your suggestion is seen by the development team and the community, and it also allows other community members to upvote and show support for your idea, which can help prioritize it for future development.
