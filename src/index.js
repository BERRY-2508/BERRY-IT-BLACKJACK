
export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname !== "/play") {
      return new Response("Not Found", { status: 404 });
    }

    const scriptUrl =
      "https://raw.githubusercontent.com/BERRY-2508/BERRY-IT-BLACKJACK/main/BERRY-IT-BLACKJACK.ps1";

    const response = await fetch(scriptUrl);

    if (!response.ok) {
      return new Response("Script unavailable", { status: 502 });
    }

    return new Response(response.body, {
      headers: {
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "no-store"
      }
    });
  }
};
