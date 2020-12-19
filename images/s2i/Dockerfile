FROM centos/ruby-25-centos7

ENV PATH=/opt/rh/rh-ruby25/root/usr/bin:$PATH

USER root

ADD ./root /

RUN bash -c "gem install bundler -v \"$(grep -A 1 'BUNDLED WITH' /opt/app-root/src/Gemfile.lock | tail -n 1)\""

RUN \
  set -x && \
  ## FIXME: why does ruby-25 need to be disabled for the build to work
  yum-config-manager --disable cbs.centos.org_repos_sclo7-rh-ruby25-rh-candidate_x86_64_os_ && \
  # prepare installing yum and node.js
  curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
  curl --silent --location https://rpm.nodesource.com/setup_12.x | bash - && \
  yum  install -y \
  # for active storage gem
  ImageMagick poppler libpoppler libicu-devel yarn && \
  # Call restore-artifacts sscript when assembling
  sed '/Installing application source/i $STI_SCRIPTS_PATH/restore-artifacts' \
    -i $STI_SCRIPTS_PATH/assemble && \
  # Build frontend when assembling
  echo -e "\n\$STI_SCRIPTS_PATH/assemble-frontend" >> $STI_SCRIPTS_PATH/assemble && \
  # Call post-assemble script when assembling
  echo -e "\n\$STI_SCRIPTS_PATH/post-assemble" >> $STI_SCRIPTS_PATH/assemble

USER 1001

ENV RAILS_ENV=production
