require 'rails_helper'

RSpec.describe 'tasks', type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task) }

  describe 'ログイン前' do
    describe 'ページの遷移について' do
      context 'タスクの新規作成ページにアクセス' do
        it '新規作成ページへのアクセスに失敗する' do
          visit new_task_path
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end

      context 'タスクの編集ページにアクセス' do
        it '編集ページへのアクセスに失敗する' do
          visit edit_task_path(task)
          expect(page).to have_content 'Login required'
          expect(current_path).to eq login_path
        end
      end

      context 'タスクの詳細ページにアクセス' do
        it 'タスクの詳細情報が表示される' do
          visit task_path(task)
          expect(page).to have_content task.title
          expect(current_path).to eq task_path(task)
        end
      end

      context 'タスクの一覧ページにアクセス' do
        it 'すべてのユーザーのタスク情報が表示される' do
          task_list = create_list(:task, 3)
          visit tasks_path
          expect(page).to have_content task_list[0].title
          expect(page).to have_content task_list[1].title
          expect(page).to have_content task_list[2].title
          expect(current_path).to eq tasks_path
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login(user) }

    describe 'タスク新規作成' do
      context 'フォームの入力値が正常' do
        it 'タスクの新規作成が成功する' do
          visit new_task_path
          fill_in 'Title', with: 'new_title'
          fill_in 'Content', with: 'new_content'
          select 'doing', from: 'Status'
          fill_in 'Deadline', with: DateTime.new(2021, 5, 7, 8, 21)
          click_button 'Create Task'
          expect(page).to have_content 'Title: new_title'
          expect(page).to have_content 'Content: new_content'
          expect(page).to have_content 'Status: doing'
          expect(page).to have_content 'Deadline: 2021/5/7 8:21'
          expect(current_path).to eq '/tasks/1'
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの新規作成が失敗する' do
          visit new_task_path
          fill_in 'Title', with: ''
          fill_in 'Content', with: 'new_content'
          click_button 'Create Task'
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title can't be blank"
          expect(current_path).to eq tasks_path
        end
      end

      context '登録済のタイトルを使用' do
        it 'タスクの新規作成が失敗する' do
          visit new_task_path
          other_task = create (:task)
          fill_in 'Title', with: other_task.title
          fill_in 'Content', with: 'new_content'
          click_button 'Create Task'
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title has already been taken"
          expect(current_path).to eq tasks_path
        end
      end
    end

    describe 'タスクの編集' do
      let!(:task) { create(:task, user: user) }
      before { visit edit_task_path(task) }

      context 'フォームの入力値が正常' do
        it 'タスクの編集が成功する' do
          fill_in 'Title', with: 'update_title'
          fill_in 'Content', with: 'update_content'
          select 'done', from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content 'Title: update_title'
          expect(page).to have_content 'Content: update_content'
          expect(page).to have_content 'Status: done'
          expect(page).to have_content 'Task was successfully updated.'
          expect(current_path).to eq task_path(task)
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの編集が失敗する' do
          fill_in 'Title', with: ''
          fill_in 'Content', with: 'update_content'
          select 'done', from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title can't be blank"
          expect(current_path).to eq task_path(task)
        end
      end

      context '登録済のタイトルを使用' do
        it 'タスクの編集が失敗する' do
          other_task = create (:task)
          fill_in 'Title', with: other_task.title
          fill_in 'Content', with: 'update_content'
          select 'done', from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title has already been taken"
          expect(current_path).to eq task_path(task)
        end
      end
    end

    describe 'タスクの削除' do
      let!(:task) { create(:task, user: user) }

      it 'タスクが削除される' do
        visit tasks_path
        click_link 'Destroy'
        expect(page.accept_confirm).to eq "Are you sure?"
        expect(page).to have_content "Task was successfully destroyed."
        expect(current_path).to eq tasks_path
        expect(page).to have_no_content task.title
      end
    end
  end
end
