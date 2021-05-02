require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    it '全ての属性が適切に格納されていれば有効' do
      task = build(:task)
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end

    it 'タイトルがなければ無効' do
      task_without_title = build(:task, title: nil)
      expect(task_without_title).to be_invalid
      expect(task_without_title.errors[:title]).to eq ["can't be blank"]
    end

    it 'ステータスがなければ無効' do
      task_without_status = build(:task, status: nil)
      expect(task_without_status).to be_invalid
      expect(task_without_status.errors[:status]).to eq ["can't be blank"]
    end

    it '同じタイトルが重複していれば無効' do
      task = create(:task)
      task_with_duplicated_title = build(:task, title: task.title)
      expect(task_with_duplicated_title).to be_invalid
      expect(task_with_duplicated_title.errors[:title]).to eq ["has already been taken"]
    end

    it 'タイトルが別名であれば有効' do
      task = create(:task)
      task_with_another_title = build(:task, title: 'another_title')
      expect(task_with_another_title).to be_valid
      expect(task_with_another_title.errors).to be_empty
    end
  end
end
