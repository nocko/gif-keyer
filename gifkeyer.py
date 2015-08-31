import os

from twisted.application import service, internet
from twisted.internet import utils
from twisted.web import proxy
from twisted.web.server import Site, NOT_DONE_YET
from twisted.web.resource import Resource, NoResource

KEYER_SCRIPT='/'.join(['/home',os.environ['APPNAME'],'keyer.sh'])

print KEYER_SCRIPT

class GIFResource(Resource):
    def getChild(self, name, request):
        if name and not name.endswith(".gif"):
            return NoResource()
        self.name = name[:-4]
        print self.name
        return self
    
    def render_GET(self, request):
        # if not 'q' in request.args:
        #     request.setResponseCode(404)
        #     request.finish()
        #     return "Nope"
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
        d = utils.getProcessOutput(
            KEYER_SCRIPT, args=['13',self.name], env={'KEYER_STDOUT': 'yes'} )
        d.addCallbacks(_write, _error)
        return NOT_DONE_YET

root = GIFResource()
application = service.Application("keyer")
site = Site(root)
sc = service.IServiceCollection(application)
i = internet.TCPServer(8080, site)
i.setServiceParent(sc)

