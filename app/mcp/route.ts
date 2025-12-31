import { createMcpHandler } from "mcp-handler";
import { z } from "zod";
import { spawn } from "child_process";

const handler = createMcpHandler(
  async (server) => {
    server.tool(
      "amass",
      "Advanced subdomain enumeration and reconnaissance tool",
      {
        subcommand: z
          .enum(["enum", "intel"])
          .describe(
            "Operation mode: 'enum' for subdomain enumeration, 'intel' for intelligence gathering"
          ),
        domain: z
          .string()
          .optional()
          .describe("Target domain (e.g., example.com)"),
        intel_whois: z
          .boolean()
          .optional()
          .describe("Include WHOIS data when gathering intel"),
        intel_organization: z
          .string()
          .optional()
          .describe("Organization name to search in intel mode"),
        enum_type: z
          .enum(["active", "passive"])
          .optional()
          .describe("Enumeration type"),
        enum_brute: z
          .boolean()
          .optional()
          .describe("Enable brute-force subdomain discovery"),
        enum_brute_wordlist: z
          .string()
          .optional()
          .describe("Wordlist path for brute force")
      },
      async ({
        subcommand,
        domain,
        intel_whois,
        intel_organization,
        enum_type,
        enum_brute,
        enum_brute_wordlist,
      }) => {
        const args: string[] = [subcommand];

        if (subcommand === "enum") {
          if (!domain) {
            throw new Error("Domain is required for 'enum' subcommand");
          }
          args.push("-d", domain);

          if (enum_type === "passive") {
            args.push("-passive");
          }

          if (enum_brute) {
            args.push("-brute");
            if (enum_brute_wordlist) {
              args.push("-w", enum_brute_wordlist);
            }
          }
        } else if (subcommand === "intel") {
          if (!domain && !intel_organization) {
            throw new Error("Either domain or organization must be provided for 'intel'");
          }
          if (domain) {
            args.push("-d", domain);
          }
          if (intel_organization) {
            args.push("-org", intel_organization);
          }
          if (intel_whois) {
            args.push("-whois");
          }
        }

        const child = spawn("amass", args);
        let output = "";

        child.stdout.on("data", (data) => {
          output += data.toString();
        });
        child.stderr.on("data", (data) => {
          output += data.toString();
        });

        return await new Promise((resolve, reject) => {
          child.on("close", (code) => {
            if (code === 0) {
              resolve({
                content: [
                  {
                    type: "text",
                    text: output || "amass finished with no output",
                  },
                ],
              });
            } else {
              reject(
                new Error(
                  `amass exited with code ${code}. Args: ${args.join(" ")} Output: ${output}`
                )
              );
            }
          });

          child.on("error", (err) => {
            reject(new Error(`Failed to start amass: ${err.message}`));
          });
        });
      }
    );
  },
  {
    capabilities: {
      tools: {
        amass: {
          description: "Advanced subdomain enumeration and reconnaissance tool",
        },
      },
    },
  },
  {
    basePath: "",
    verboseLogs: true,
    maxDuration: 300,
    disableSse: true,
  }
);

export { handler as GET, handler as POST, handler as DELETE };
