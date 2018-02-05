<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; &nbsp; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}
  </span>
  <span class="with-love">
    <i class="icon-next-heart"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ config.author }}
  </span>
</div>
<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=298 height=52 src="//music.163.com/outchain/player?type=2&id=479223325&auto=1&height=32"></iframe>
{% block footer %}{% endblock %}
