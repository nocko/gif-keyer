import os

from twisted.application import service, internet
from twisted.internet import defer, protocol, reactor
from twisted.python import log
from twisted.web import proxy
from twisted.web.server import Site, NOT_DONE_YET
from twisted.web.static import File
from twisted.web.resource import Resource, NoResource

KEYER_SCRIPT='/'.join(['/home',os.environ['APPNAME'],'keyer.sh'])
PROC_LIMIT=2
DEFAULT_WPM='13'
MAX_MEM=100 # IN MB concurrent usage by ImageMagick
PER_PROC_MEM=str(MAX_MEM//PROC_LIMIT)+'MB'

sem = defer.DeferredSemaphore(PROC_LIMIT)

class GIFKeyerProtocol(protocol.ProcessProtocol):
    def __init__(self, request):
        self.request = request
        self.request.setHeader("Content-Type", "image/gif")

    def outReceived(self, data):
        self.request.write(data)

    def errReceived(self, data):
        log.msg("errRx: {}".format(data)) 
    
    def processEnded(self, status):
        rc = status.value.exitCode
        if rc == 0:
            self.deferred.callback(self)
        else:
            self.deferred.errback(rc)
    
class GIFResource(Resource):
    def _cache_path(self):
        return '/'.join(['gifs', self.wpm, self.name])

    def getChild(self, name, request):
        if name and name.endswith(".gif"):
            self.name = name
            self.wpm=request.args['wpm'][0] if 'wpm' in request.args else DEFAULT_WPM
            self.path = self._cache_path()
            if os.path.isfile(self.path):
                return File(self.path)
            return self
        return File("public/"+name)
    
    def render_GET(self, request):
        def _finished(proto_inst):
            request.finish()
        def _error(f):
            log.msg("Error: {}".format(f))
            request.finish()
        def _run_proc():
            proto = GIFKeyerProtocol(request)
            proto.deferred = defer.Deferred()
            env={'KEYER_WEB': '1',
                 'KEYER_OUTPUT': self.name,
                 'KEYER_WPM': self.wpm,
                 'LC_ALL': 'C',
                 'MAGICK_MEMORY_LIMIT': PER_PROC_MEM,
                 'MAGICK_MEMORY_MAP': PER_PROC_MEM,
                 'KEYUP_PIC': os.environ['KEYUP_PIC'],
                 'KEYDOWN_PIC': os.environ['KEYDOWN_PIC']}
            reactor.spawnProcess(
                proto, KEYER_SCRIPT,
                args=['keyer.sh', self.name[:-4]],
                env=env)
            return proto.deferred
        d = sem.run(_run_proc)
        d.addCallbacks(_finished,_error)
        return NOT_DONE_YET

root = GIFResource()
application = service.Application("keyer")
site = Site(root)
sc = service.IServiceCollection(application)
i = internet.TCPServer(8080, site)
i.setServiceParent(sc)

