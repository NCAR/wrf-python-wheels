########################################
Building and uploading wrf-python wheels
########################################

We automate wheel building using this custom github repository
(based on https://github.com/MacPython/scipy-wheels) that builds on
the travis-ci OSX machines, travis-ci Linux machines, and the Appveyor VMs.

The travis-ci interface for the builds is
https://travis-ci.org/NCAR/wrf-python-wheels

Appveyor interface at
https://ci.appveyor.com/project/NCAR/wrf-python-wheels

The driving github repository is
https://github.com/NCAR/wrf-python-wheels

How it works
============

The wheel-building repository:

* builds a wrf-python wheel
* processes the wheel using delocate_ (OSX) or auditwheel_ ``repair``
  (Manylinux1_).  ``delocate`` and ``auditwheel`` copy the required dynamic
  libraries into the wheel and relinks the extension modules against the
  copied libraries;
* uploads the built wheels to https://7933911d6844c6c53a7d-47bd50c35cd79bd838daf386af554a83.ssl.cf2.rackcdn.com (a Rackspace container
  kindly donated by Rackspace to scikit-learn).

The resulting wheels are therefore self-contained and do not need any external
dynamic libraries apart from those provided as standard by OSX / Linux as
defined by the manylinux1 standard.

The ``.travis.yml`` file in this repository has a line containing the API key
for the Rackspace container encrypted with an RSA key that is unique to the
repository - see http://docs.travis-ci.com/user/encryption-keys.  This
encrypted key gives the travis build permission to upload to the Rackspace
directory pointed to by https://7933911d6844c6c53a7d-47bd50c35cd79bd838daf386af554a83.ssl.cf2.rackcdn.com.

Triggering a build
==================

Edit the ``BUILD_COMMIT`` file with the new git tag or branch to build,
commit and push. This will trigger builds and upload the wheels to Rackspace.

If you don't want to change the ``BUILD_COMMIT`` file but still trigger new builds
then make an empty commit with ``git commit --allow-empty``.

Which wrf-python commit does the repository build?
===============================================

The ``wrf-python-wheels`` repository will build the commit specified in the
``BUILD_COMMIT`` file.
This can be any naming of a commit, including branch name, tag name or commit
hash.

Uploading the built wheels to pypi
==================================

Be careful, https://7933911d6844c6c53a7d-47bd50c35cd79bd838daf386af554a83.ssl.cf2.rackcdn.com
points to a container on a distributed
content delivery network.  It can take up to 15 minutes for the new wheel file
to get updated into the container.

When the wheels are updated, you can download them to your machine manually,
and then upload them manually to pypi, or by using twine_.  You can also use a
script for doing this, housed at :
https://github.com/MacPython/terryfy/blob/master/wheel-uploader

For the ``wheel-uploader`` script, you'll need twine and `beautiful soup 4
<bs4>`_.

You will typically have a directory on your machine where you store wheels,
called a `wheelhouse`.   The typical call for `wheel-uploader` would then
be something like::

    VERSION=1.3.2
    CDN_URL=https://7933911d6844c6c53a7d-47bd50c35cd79bd838daf386af554a83.ssl.cf2.rackcdn.com
    wheel-uploader -u $CDN_URL -s -v -w ~/wheelhouse -t all wrf_python $VERSION

where:

* ``-u`` gives the URL from which to fetch the wheels, here the https address,
  for some extra security;
* ``-s`` causes twine to sign the wheels with your GPG key;
* ``-v`` means give verbose messages;
* ``-w ~/wheelhouse`` means download the wheels from to the local directory
  ``~/wheelhouse``.

`wrf_python` is the root name of the wheel(s) to download / upload and `1.0.5` is
the version to download / upload.

In order to upload the wheels, you will need something like this
in your ``~/.pypirc`` file::

    [distutils]
    index-servers =
        pypi

    [pypi]
    username:your_user_name
    password:your_password

So, in this case, `wheel-uploader` will download all wheels starting with
`wrf_python-1.3.2-` from the URL in ``$CDN_URL`` above to ``~/wheelhouse``, then
upload them to pypi.

Of course, you will need permissions to upload to PyPI, for this to work.

.. _manylinux1: https://www.python.org/dev/peps/pep-0513
.. _twine: https://pypi.python.org/pypi/twine
.. _bs4: https://pypi.python.org/pypi/beautifulsoup4
.. _delocate: https://pypi.python.org/pypi/delocate
.. _auditwheel: https://pypi.python.org/pypi/auditwheel
