// Serve the graphical Blackjack edition by default; keep classic at /play-classic.
export default {
  async fetch(request) {
    const url = new URL(request.url);
    const files = {
      "/play": "BERRY-IT-BLACKJACK-GUI.ps1",
      "/play-classic": "BERRY-IT-BLACKJACK.ps1"
    };
    const filename = files[url.pathname];
    if (!filename) return new Response("Not Found", { status: 404 });
    const scriptUrl = "https://raw.githubusercontent.com/BERRY-2508/BERRY-IT-BLACKJACK/main/" + filename;
    const response = await fetch(scriptUrl, { cf: { cacheTtl: 0 } });
    if (!response.ok) return new Response("Script unavailable", { status: 502 });
    return new Response(response.body, {
      headers: {
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "no-store, max-age=0",
        "X-Content-Type-Options": "nosniff"
      }
    });
  }
};
