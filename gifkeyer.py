import os

from twisted.application import service, internet
from twisted.internet import utils, defer
from twisted.web import proxy
from twisted.web.server import Site, NOT_DONE_YET
from twisted.web.static import File
from twisted.web.resource import Resource, NoResource

KEYER_SCRIPT='/'.join(['/home',os.environ['APPNAME'],'keyer.sh'])

sem = defer.DeferredSemaphore(1)

class GIFResource(Resource):
    def getChild(self, name, request):
        if name and not name.endswith(".gif"):
            return NoResource()
        self.name = name
        if os.path.isfile('gifs/'+name):
            return File('gifs/'+name)
        return self
    
    def render_GET(self, request):
        if not self.name:
            return "Try: /[some word or phrase].gif"
        request.setHeader("Content-Type", "image/gif")
        def _write(data):
            request.write(data)
            request.finish()
        def _error(f):
            print f
            request.setResponseCode(400)
            request.finish()
        def _run_proc():
            return utils.getProcessOutput(
                KEYER_SCRIPT,
                args=['13',self.name[:-4]],
                env={'KEYER_STDOUT': self.name})
        d = sem.run(_run_proc)
        d.addCallbacks(_write, _error)
        return NOT_DONE_YET

root = GIFResource()
application = service.Application("keyer")
site = Site(root)
sc = service.IServiceCollection(application)
i = internet.TCPServer(8080, site)
i.setServiceParent(sc)

