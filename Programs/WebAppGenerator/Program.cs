using System.Net;
/// <summary>Package to retrieve and traverse HTML.</summary>
using HtmlAgilityPack;
using ModifierFunc = System.Action<HtmlAgilityPack.HtmlNode>;

/// <summary>Identified extensions.</summary>
var types = new Dictionary<string, string[]>(){
    { "stylesheet", new string[] {".css"}},
    { "script",     new string[] {".js"}},
    { "style",      new string[] {".css"}},
    { "font",       new string[] {".ttf", ".woff2"}},
    { "link",       new string[] {".com", ".io", ".us", ".ru", ".co", ".cn",
                                  ".org", ".cl", ".de", ".dk", ".es", ".fr",
                                  ".uk", ".jp", ".kr", ".nz", ".pt", ".se",
                                  ".net", ".br", ".ms", ".pl", ".ca", ".it",
                                  ".ph", ".nl", ".hk", ".sg", ".ch", ".ie",
                                  ".au", ".at", ".be", ".my", ".tv", ".in",
                                  ".int", ".party", ".gov"}},
    { "img",        new string[] {".png", ".jpg", ".jpeg", ".ico", ".svg"}},
};

/// <summary>Identified values for rel attribute to skip.</summary>
var skipList = new string[]
{
    "dns-prefetch", "canonical", "copyright", "next", 
    "alternate", "contents", "home", "help", "https://api.w.org/", 
    "preconnect"
};

/// <summary>User agent for Google Chrome mobile browser.</summary>
var chromeUserAgent = "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.5195.136 Mobile Safari/537.36";

/// <summary>List of experiments to execute.</summary>
var experiments = new List<(string, Dictionary<Types, ModifierFunc>)>()
{
    ("none-applied", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, RemoveHint },
        { Types.Image, RemoveHint },
        { Types.Links, RemoveHint},
        { Types.StyleSheets, RemoveHint},
        { Types.Fonts , DoNothing },
    }),
    ("stylesheet-prefetch", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, RemoveHint },
        { Types.Image, RemoveHint },
        { Types.Links, RemoveHint},
        { Types.StyleSheets, AddPrefetch},
        { Types.Fonts , DoNothing },
    }),
    ("image-prefetch", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, RemoveHint },
        { Types.Image, AddPrefetch },
        { Types.Links, RemoveHint},
        { Types.StyleSheets, RemoveHint},
        { Types.Fonts , DoNothing },
    }),
    ("script-prefetch", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, AddPrefetch },
        { Types.Image, RemoveHint },
        { Types.Links, RemoveHint},
        { Types.StyleSheets, RemoveHint},
        { Types.Fonts , DoNothing },
    }),
    ("stylesheet-preload", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, RemoveHint },
        { Types.Image, RemoveHint },
        { Types.Links, RemoveHint},
        { Types.StyleSheets, AddPreload},
        { Types.Fonts , DoNothing },
    }),
    ("image-preload", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, RemoveHint },
        { Types.Image, AddPreload },
        { Types.Links, RemoveHint},
        { Types.StyleSheets, RemoveHint},
        { Types.Fonts , DoNothing },
    }),
    ("script-preload", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, AddPreload },
        { Types.Image, RemoveHint },
        { Types.Links, RemoveHint},
        { Types.StyleSheets, RemoveHint},
        { Types.Fonts , DoNothing },
    }),
    ("url-preconnect", new Dictionary<Types, ModifierFunc>()
    {
        { Types.Script, RemoveHint },
        { Types.Image, RemoveHint },
        { Types.Links, AddPreconnect },
        { Types.StyleSheets, RemoveHint},
        { Types.Fonts , DoNothing },
    }),
};

var uriOptions = new UriCreationOptions
{
    DangerousDisablePathAndQueryCanonicalization = false
};

/// <summary>Client to download resources.</summary>
var documentClient = new HttpClient();
/// <summary>File with URLs to generate.</summary>
var websites = File.ReadAllLines(".\\webapps.txt");
/// <summary>Path to store generated websites.</summary>
var resultsBasePath = ".\\Webapps";
if(!Directory.Exists(resultsBasePath))
    Directory.CreateDirectory(resultsBasePath);
foreach (var (experimentName, modifiers) in experiments)
{
    /// <summary>Path to store websites by experiment.</summary>
    var experimentPath = $"{resultsBasePath}\\{experimentName}";
    if (!Directory.Exists(experimentPath))
        Directory.CreateDirectory(experimentPath);
    Parallel.ForEachAsync(websites, async (websiteUrl, token) =>
    {
        var host = new Uri(websiteUrl);
        var normHost = NormalizeHost(host.Host);
        var resDir = $"{normHost}-rec";
        /// <summary>Path to store the linked resources of the website.</summary>
        var webResource = $"{experimentPath}\\{resDir}";
        Directory.CreateDirectory(webResource);
        try
        {
            /// <summary>Load the website.</summary>
            var generator = new HtmlWeb() { UserAgent = chromeUserAgent };
            var document = await generator.LoadFromWebAsync(websiteUrl, token);
            if (generator.StatusCode != HttpStatusCode.OK)
            {
                Console.WriteLine($"Failed to retrieve {websiteUrl}");
                return;
            }

            /// <summary>Walk through the links in the HTML body.</summary>
            foreach (var link in document.DocumentNode.Descendants("link"))
            {
                if (link is null) continue;
                /// <summary>Identify the link.</summary>
                var linkType = IdentifyLink(link);
                /// <summary>Skip if unknown.</summary>
                if (linkType == Types.Unknown) continue;
                /// <summary>Get and apply modifier function for link type.</summary>
                var modifier = modifiers[linkType];
                modifier(link);

                var href = link.Attributes["href"]?.Value;
                if (href is null) continue;
                /// <summary>Try to retrieve resource.</summary>
                var result = await DownloadResource(documentClient, href, webResource, websiteUrl);
                if (result)
                {
                    var newHref = ChangeUri(resDir, href);
                    /// <summary>Replace href attribute with locally available resource.</summary>
                    link.SetAttributeValue("href", newHref);
                }
            }
            /// <summary>Store modified HTML.</summary>
            document.Save($"{experimentPath}\\{normHost}.html");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to retrieve {websiteUrl}");
            Console.WriteLine(ex.Message);
            return;
        }
    }).Wait();
}

bool InHead(HtmlNode node)
    => node.ParentNode.Name == "head";

/// <summary>Replace dots for underscores on the string.</summary>
string NormalizeHost(string host) 
    => host.Replace('.', '_');

/// <summary>Try to retrieve file from remote server.</summary>
async Task<bool> DownloadResource(HttpClient client, string href, string savePath, string host) {
    if(!Uri.TryCreate(href, UriKind.RelativeOrAbsolute, out var uri) && uri.HostNameType == UriHostNameType.Unknown){
        Console.WriteLine($"invalid URI {href}");
        return false;
    }
    if(!uri.IsAbsoluteUri){
        var startIndex = href.StartsWith('.') ? 1 : 0;
        href = $"{host}/{href[1..]}";
    }
    var name = NormalizeFileName(href);
    var fileName = $"{savePath}\\{name}";
    if (File.Exists(fileName)) return true;
    if (!href.StartsWith('h')) href = $"https:{href}";
    var responseTask = client.GetAsync(href);
    var response = await responseTask;
    try
    {
        using var fs = new FileStream(fileName, FileMode.CreateNew);
        await response.Content.CopyToAsync(fs);
        return true;
    }
    catch (Exception ex)
    {
        Console.WriteLine(ex);
    }
    return false;
}

/// <summary>Find file name of path.</summary>
string NormalizeFileName(string href)
{
    var name = GetFileName(href);
    var index = name.IndexOf("?");
    if (index < 0) return name;
    return name[..index];
}

string GetFileName(string href){
    var splitted = href.Split('/');
    return splitted[^1];
}

string ChangeUri(string host, string href) {
    var uri = new Uri(href, UriKind.RelativeOrAbsolute);
    if (uri.IsAbsoluteUri) return href;
    var fileName = NormalizeFileName(href);
    return $"{host}\\{fileName}";
}

/// <summary>Identify link node based on attributes.</summary>
Types IdentifyLink(HtmlNode node)
{
    var @as = node.Attributes["as"];
    var href = node.Attributes["href"];
    var rel = node.Attributes["rel"];
    var linkType = node.Attributes["type"];
    var @class = node.Attributes["class"];
    var extras = node.Attributes["itemprop"];
    var type = Types.Unknown;
    
    if (type == Types.Unknown && @class is not null && @class.Value != string.Empty)
    {
        if (@class.Value == "lazyload")
        {
            type = Types.Unknown;
            return type;
        }
    }
    if(type == Types.Unknown &&  extras is not null && extras.Value != string.Empty)
    {
        if(extras.Value == "sameAs")
            return type;
    }
    if (type == Types.Unknown && @as is not null && @as.Value != string.Empty)
    {
        foreach (var split in @as.Value.Split(' '))
        {
            type = GetType(split.ToLowerInvariant());
            if (type != Types.Unknown)
                break;
        }
    }
    if (type == Types.Unknown && rel is not null && rel.Value != string.Empty)
    {
        foreach (var split in rel.Value.Split(' '))
        {
            type = GetType(split.ToLowerInvariant());
            if (skipList.Contains(split))
                return Types.Unknown;
            if (type != Types.Unknown)
                break;
        }
    }
    if (type == Types.Unknown && href is not null && href.Value != string.Empty)
    {
        if(Uri.TryCreate(href.Value, in uriOptions, out var uri))
        {
            var extension = Path.GetExtension(uri.LocalPath);
            if (extension == string.Empty)
            {
                var lastDot = uri.Host.LastIndexOf('.');
                if(lastDot != -1)
                {
                    var topDomain = uri.Host[lastDot..];
                    if (types["link"].Contains(topDomain))
                        type = Types.Links;

                }
            }
            else
            {
                foreach (var (k, item) in types)
                    if (item.Contains(extension))
                        type = GetType(k);
            }
        }
    }
    if (type == Types.Unknown && linkType is not null && linkType.Value != string.Empty)
        type = GetType(linkType.Value);
    return type;
}

Types GetType(string type)
    => type switch
    {
        "script" => Types.Script,
        "image" => Types.Image,
        "icon" => Types.Image,
        "logo" => Types.Image,
        "font" => Types.Fonts,
        "link" => Types.Links,
        "stylesheet" => Types.StyleSheets,
        "style" => Types.StyleSheets,
        "text/css" => Types.StyleSheets,
        "mask-icon" => Types.Image,
        "Icon" => Types.Image,
        "apple-touch-icon" => Types.Image,
        "apple-touch-icon-precomposed" => Types.Image,
        "apple-touch-startup-image" => Types.Image,
        "image_src" => Types.Image,
        "light-mode-icon" => Types.Image,
        "dark-mode-icon" => Types.Image,
        "dns-prefetch" => Types.Unknown,
        _ => Types.Unknown,
    };

void AddPrefetch(HtmlNode node)
    => AddRel(node, "prefetch");

void RemoveHint(HtmlNode node) 
{
    var currRel = node.Attributes["rel"];
    if (currRel is null) return;
    var newRel = currRel.Value.Replace("prefetch", string.Empty);
    newRel = currRel.Value.Replace("preconnect", string.Empty);
    newRel = currRel.Value.Replace("preload", string.Empty);
    node.SetAttributeValue("rel", newRel);
}

void AddPreload(HtmlNode node) 
{
    if (!InHead(node)) return;
    AddRel(node, "preload");
}

void AddPreconnect(HtmlNode node)
    => AddRel(node, "preconnect");

void AddRel(HtmlNode node, string hint)
{
    var currRel = node.Attributes["rel"];
    var newRel = currRel is null ? hint : currRel.Value + " " + hint;
    node.SetAttributeValue("rel", newRel);

}

void DoNothing(HtmlNode node) { }

enum Types
{
    Unknown,
    Script,
    Image,
    Fonts,
    Links,
    StyleSheets,
}
