require File.expand_path('../test_helper', __FILE__)

module FriendlyId
  module Test
    module ActiveRecordAdapter

      class CachedSlugTest < ::Test::Unit::TestCase

        include FriendlyId::Test::Generic
        include FriendlyId::Test::Slugged
        include FriendlyId::Test::DataMapperAdapter::Slugged
        include FriendlyId::Test::DataMapperAdapter::Core

        def klass
          District
        end

        def other_class
          Post
        end

        def cached_slug
          instance.send(cache_column)
        end

        def cache_column
          klass.friendly_id_config.cache_column
        end

        test "should have a cached_slug" do
          assert_equal cached_slug, instance.slug.to_friendly_id
        end

        test "should protect the cached slug value" do
          old_value = cached_slug
          instance.attributes(cache_column => "Madrid")
          instance.save
          instance.reload
          assert_equal old_value, cached_slug
        end

        test "should update the cached slug when updating the slug" do
          instance.attributes(:name => "new name")
          assert_equal instance.slug.to_friendly_id, cached_slug
        end

        test "should not update the cached slug column if it has not changed" do
          instance.note = "a note"
          instance.expects("#{cache_column}=".to_sym).never
          instance.save!
        end

        test "should cache the incremented sequence for duplicate slug names" do
          instance_2 = klass.create(:name => instance.name)
          assert_match(/2\z/, instance_2.send(cache_column))
        end

        test "#friendly_id should check the cached value by default" do
          instance.expects(:slug).never
          instance.friendly_id
        end

        test "#friendly_id should skip the cache if invoked with true" do
          instance.expects(:slug)
          instance.friendly_id(true)
        end

      end
    end
  end
end
