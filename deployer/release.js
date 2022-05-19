const YAML = require("yaml");
const { execSync } = require("child_process");
const COS = require("cos-nodejs-sdk-v5");
const { env } = require("process");
const {
  createReadStream,
  readFileSync,
  createWriteStream,
  existsSync,
  writeFileSync,
} = require("fs");
const cosInstance = new COS({
  SecretId: env["COS_SECRET_ID"],
  SecretKey: env["COS_SECRET_KEY"],
  UseAccelerate: true,
});
const cosBucket = "mpflutter-dist-1253771526";
const cosRegion = "ap-guangzhou";

const currentVersion = env["GITHUB_REF_NAME"];

class DartPackageDeployer {
  constructor(name) {
    this.name = name;
  }

  async deploy() {
    console.log("[start]deploying package" + this.name, new Date().toString());
    this.replaceVersion();
    this.makeArchive();
    const archiveUrl = await this.uploadArchive();
    const pubspec = this.makePubspec(archiveUrl);
    await this.updatePackage(pubspec);
    console.log("[end]deploying package" + this.name, new Date().toString());
  }

  replaceVersion() {
    const originYaml = YAML.parse(
      readFileSync(`../packages/${this.name}/pubspec.yaml`, {
        encoding: "utf-8",
      })
    );
    originYaml.version = currentVersion;
    writeFileSync(
      `../packages/${this.name}/pubspec.yaml`,
      YAML.stringify(originYaml)
    );
  }

  makeArchive() {
    execSync(`tar -czf ${currentVersion}.tar.gz *`, {
      cwd: `../packages/${this.name}`,
    });
    execSync(
      `mv ${currentVersion}.tar.gz /tmp/${this.name}${currentVersion}.tar.gz`,
      {
        cwd: `../packages/${this.name}`,
      }
    );
  }

  uploadArchive() {
    return new Promise((res, rej) => {
      cosInstance.putObject(
        {
          Bucket: cosBucket,
          Region: cosRegion,
          Key: `/${this.name}/versions/${currentVersion}.tar.gz`,
          StorageClass: "STANDARD",
          Body: createReadStream(`/tmp/${this.name}${currentVersion}.tar.gz`),
        },
        (err, data) => {
          if (!err) {
            res(
              `https://dist.mpflutter.com/${this.name}/versions/${currentVersion}.tar.gz`
            );
          } else {
            rej(err)
          }
        }
      );
    });
  }

  makePubspec(archiveUrl) {
    const originYaml = YAML.parse(
      readFileSync(`../packages/${this.name}/pubspec.yaml`, {
        encoding: "utf-8",
      })
    );
    return {
      version: currentVersion,
      pubspec: {
        version: currentVersion,
        name: this.name,
        author: originYaml.author || "MPFlutter",
        description: originYaml.description || "/",
        homepage: originYaml.homepage || "/",
        environment: {
          sdk: originYaml.environment?.sdk
            ? originYaml.environment.sdk
            : undefined,
          flutter: originYaml.environment?.flutter
            ? originYaml.environment.flutter
            : undefined,
        },
        dependencies: originYaml.dependencies || {},
        dev_dependencies: originYaml.dev_dependencies || {},
      },
      archive_url: archiveUrl,
      published: new Date().toISOString(),
    };
  }

  updatePackage(pubspec) {
    return new Promise((res, rej) => {
      cosInstance.getObject(
        {
          Bucket: cosBucket,
          Region: cosRegion,
          Key: `/${this.name}/package.json`,
          Output: createWriteStream(`/tmp/${this.name}.package.json`),
        },
        () => {
          let contents = "{}";
          if (existsSync(`/tmp/${this.name}.package.json`)) {
            contents = readFileSync(`/tmp/${this.name}.package.json`, {
              encoding: "utf-8",
            });
          }
          let pkgJSON = (() => {
            try {
              return JSON.parse(contents);
            } catch (error) {
              return {};
            }
          })();
          pkgJSON["name"] = this.name;
          if (currentVersion !== "0.0.1-master") {
            pkgJSON["latest"] = pubspec;
          }
          if (!pkgJSON["versions"]) {
            pkgJSON["versions"] = [];
          }
          let replaced = false;
          for (let index = 0; index < pkgJSON["versions"].length; index++) {
            const element = pkgJSON["versions"][index];
            if (element.version === currentVersion) {
              pkgJSON["versions"][index] = pubspec;
              replaced = true;
            }
          }
          if (!replaced) {
            pkgJSON["versions"].push(pubspec);
          }
          writeFileSync(
            `/tmp/${this.name}.package.json`,
            JSON.stringify(pkgJSON)
          );
          cosInstance.putObject(
            {
              Bucket: cosBucket,
              Region: cosRegion,
              Key: `/${this.name}/package.json`,
              StorageClass: "STANDARD",
              Body: createReadStream(`/tmp/${this.name}.package.json`),
            },
            (err, data) => {
              if (!err) {
                res(null);
              } else {
                res(rej);
              }
            }
          );
        }
      );
    });
  }
}

(async () => {
  await new DartPackageDeployer("flutter").deploy();
  await new DartPackageDeployer("flutter_web_plugins").deploy();
  await new DartPackageDeployer("mpcore").deploy();
  await new DartPackageDeployer("mp_build_tools").deploy();
})();
